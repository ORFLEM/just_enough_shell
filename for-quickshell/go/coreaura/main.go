package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"math"
	"os"
	"os/exec"
	"os/signal"
	"os/user"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/BurntSushi/toml"
	"github.com/godbus/dbus/v5"
)

const (
	busName  = "org.jes.CoreAura"
	busPath  = "/org/jes/CoreAura"
	busIFace = "org.jes.CoreAura"
)

// ---------- config ----------

type CoreAuraCfg struct {
	Enabled                 bool     `toml:"enabled"`
	KernelPriorityMax       int      `toml:"kernel_priority_max"`
	Services                []string `toml:"services"`
	LogTailLines            int      `toml:"log_tail_lines"`
	ResourcePollIntervalSec int      `toml:"resource_poll_interval_sec"`
	CPUThresholdPercent     int      `toml:"cpu_threshold_percent"`
	GPUThresholdPercent     int      `toml:"gpu_threshold_percent"`
	DedupWindowSec          int      `toml:"dedup_window_sec"`
}

type Config struct {
	CoreAura CoreAuraCfg `toml:"CoreAura"`
}

// ---------- bus selection ----------

var useSessionBus bool

func getBus() (*dbus.Conn, error) {
	if useSessionBus {
		return dbus.SessionBus()
	}
	return dbus.SystemBus()
}

// ---------- service ----------

type CoreAura struct {
	conn *dbus.Conn
	cfg  CoreAuraCfg

	mu  sync.Mutex
	uis map[string]*UIEntry

	dedupMu     sync.Mutex
	dedupMap    map[string]*dedupEntry
	lastCleanup time.Time
}

type UIEntry struct {
	PID     uint32
	UID     uint32
	LogPath string
	Started time.Time
}

type dedupEntry struct {
	firstSeen  time.Time
	lastEmit   time.Time
	suppressed int
}

// ---------- D-Bus methods ----------

func (c *CoreAura) RegisterUI(pid uint32, uid uint32, logPath string) (string, *dbus.Error) {
	token := fmt.Sprintf("%d-%d-%d", pid, uid, time.Now().UnixNano())
	c.mu.Lock()
	c.uis[token] = &UIEntry{PID: pid, UID: uid, LogPath: logPath, Started: time.Now()}
	c.mu.Unlock()
	c.logf("[ui] registered pid=%d uid=%d log=%s token=%s", pid, uid, logPath, token)
	c.emit("UIRegistered", pid, uid)
	return token, nil
}

func (c *CoreAura) UnregisterUI(token string) *dbus.Error {
	c.mu.Lock()
	if e, ok := c.uis[token]; ok {
		c.logf("[ui] unregistered pid=%d token=%s", e.PID, token)
		delete(c.uis, token)
	}
	c.mu.Unlock()
	return nil
}

func (c *CoreAura) GetStatus() (map[string]dbus.Variant, *dbus.Error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	uis := make([]string, 0, len(c.uis))
	for tok, e := range c.uis {
		uis = append(uis, fmt.Sprintf("%s:pid=%d,uid=%d", tok, e.PID, e.UID))
	}
	return map[string]dbus.Variant{
		"version":     dbus.MakeVariant("1.0.0"),
		"ui_count":    dbus.MakeVariant(uint32(len(c.uis))),
		"kernel_prio": dbus.MakeVariant(uint32(c.cfg.KernelPriorityMax)),
		"services":    dbus.MakeVariant(c.cfg.Services),
		"registered":  dbus.MakeVariant(uis),
	}, nil
}

func (c *CoreAura) GetResourceStatus() (string, *dbus.Error) {
	sample, _, _ := sampleResources(c.cfg)
	payload, _ := json.Marshal(sample)
	return string(payload), nil
}

// ---------- helpers ----------

func (c *CoreAura) emit(name string, args ...any) {
	_ = c.conn.Emit(dbus.ObjectPath(busPath), busIFace+"."+name, args...)
}

func (c *CoreAura) logf(format string, args ...any) {
	line := fmt.Sprintf("[%s] %s",
		time.Now().Format("2006-01-02 15:04:05"),
		fmt.Sprintf(format, args...))
	fmt.Println(line)
}

// normalizeBody разворачивает вложенные JSON-строки в body,
// чтобы избежать двойного экранирования при сериализации.
func normalizeBody(body []any) []any {
	out := make([]any, len(body))
	for i, v := range body {
		s, ok := v.(string)
		if !ok {
			out[i] = v
			continue
		}
		trimmed := strings.TrimSpace(s)
		if len(trimmed) > 0 && (trimmed[0] == '{' || trimmed[0] == '[') {
			var parsed any
			if err := json.Unmarshal([]byte(trimmed), &parsed); err == nil {
				out[i] = parsed
				continue
			}
		}
		out[i] = v
	}
	return out
}

// ---------- dedup ----------

func (c *CoreAura) shouldEmitKernel(prio int, sub, msg string) (bool, int) {
	key := strconv.Itoa(prio) + "|" + sub + "|" + msg
	now := time.Now()
	window := time.Duration(c.cfg.DedupWindowSec) * time.Second

	c.dedupMu.Lock()
	defer c.dedupMu.Unlock()

	if now.Sub(c.lastCleanup) > 60*time.Second {
		cutoff := now.Add(-5 * time.Minute)
		for k, e := range c.dedupMap {
			if e.lastEmit.Before(cutoff) {
				delete(c.dedupMap, k)
			}
		}
		c.lastCleanup = now
	}

	e, exists := c.dedupMap[key]
	if !exists {
		c.dedupMap[key] = &dedupEntry{
			firstSeen:  now,
			lastEmit:   now,
			suppressed: 0,
		}
		return true, 0
	}

	if now.Sub(e.lastEmit) < window {
		e.suppressed++
		return false, e.suppressed
	}

	n := e.suppressed
	e.lastEmit = now
	e.suppressed = 0
	return true, n
}

// ---------- kernel ----------

type journalEntry struct {
	Priority         string          `json:"PRIORITY"`
	Message          json.RawMessage `json:"MESSAGE"`
	SyslogIdentifier string          `json:"SYSLOG_IDENTIFIER"`
}

func (c *CoreAura) kernelWatcher() {
	for {
		args := []string{"-f", "-n", "0", "-k", "-o", "json", "--no-pager",
			"-p", strconv.Itoa(c.cfg.KernelPriorityMax)}
		c.logf("kernel watcher: journalctl %s", strings.Join(args, " "))
		cmd := exec.Command("journalctl", args...)
		stdout, err := cmd.StdoutPipe()
		if err != nil {
			time.Sleep(5 * time.Second)
			continue
		}
		if err := cmd.Start(); err != nil {
			time.Sleep(5 * time.Second)
			continue
		}
		sc := bufio.NewScanner(stdout)
		sc.Buffer(make([]byte, 0, 64*1024), 1<<20)
		for sc.Scan() {
			c.handleJournalLine(sc.Bytes())
		}
		_ = cmd.Wait()
		time.Sleep(5 * time.Second)
	}
}

func (c *CoreAura) handleJournalLine(line []byte) {
	var e journalEntry
	if err := json.Unmarshal(line, &e); err != nil {
		return
	}
	prio, err := strconv.Atoi(e.Priority)
	if err != nil || prio > c.cfg.KernelPriorityMax {
		return
	}
	msg := decodeMsg(e.Message)
	sub := e.SyslogIdentifier
	if sub == "" {
		sub = "kernel"
	}

	emit, suppressed := c.shouldEmitKernel(prio, sub, msg)
	if !emit {
		return
	}

	sev := map[int]string{0: "EMERG", 1: "ALERT", 2: "CRIT", 3: "ERR"}[prio]
	if sev == "" {
		sev = fmt.Sprintf("P%d", prio)
	}

	outMsg := msg
	if suppressed > 0 {
		outMsg = fmt.Sprintf("%s (suppressed %d duplicates)", msg, suppressed)
	}

	c.logf("[kernel/%s] %s: %s", sev, sub, outMsg)
	c.emit("KernelError", byte(prio), sub, outMsg)
}

func decodeMsg(raw json.RawMessage) string {
	var s string
	if json.Unmarshal(raw, &s) == nil {
		return s
	}
	var bs []byte
	if json.Unmarshal(raw, &bs) == nil {
		return string(bs)
	}
	var arr []int
	if json.Unmarshal(raw, &arr) == nil {
		b := make([]byte, len(arr))
		for i, v := range arr {
			b[i] = byte(v)
		}
		return string(b)
	}
	return string(raw)
}

// ---------- systemd ----------

var (
	svcMu        sync.Mutex
	svcLastState = map[string]string{}
	svcRestarts  = map[string]uint32{}
	watchedUnits = map[string]bool{}
)

func normalizeUnit(name string) string {
	if !strings.Contains(name, ".") {
		return name + ".service"
	}
	return name
}

func unescapeUnit(name string) string {
	var out []byte
	for i := 0; i < len(name); i++ {
		if name[i] == '_' && i+2 < len(name) {
			if v, err := strconv.ParseUint(name[i+1:i+3], 16, 8); err == nil {
				out = append(out, byte(v))
				i += 2
				continue
			}
		}
		out = append(out, name[i])
	}
	return string(out)
}

func (c *CoreAura) systemdWatcher() {
	for _, s := range c.cfg.Services {
		watchedUnits[normalizeUnit(s)] = true
	}
	units := make([]string, 0, len(watchedUnits))
	for u := range watchedUnits {
		units = append(units, u)
	}
	c.logf("systemd watcher: %v", units)

	manager := c.conn.Object("org.freedesktop.systemd1", "/org/freedesktop/systemd1")
	if call := manager.Call("org.freedesktop.systemd1.Manager.Subscribe", 0); call.Err != nil {
		c.logf("systemd Subscribe failed: %v", call.Err)
		return
	}
	c.logf("systemd watcher: subscribed to manager signals")

	if err := c.conn.AddMatchSignal(
		dbus.WithMatchInterface("org.freedesktop.DBus.Properties"),
		dbus.WithMatchMember("PropertiesChanged"),
		dbus.WithMatchPathNamespace("/org/freedesktop/systemd1/unit"),
	); err != nil {
		c.logf("AddMatchSignal failed: %v", err)
		return
	}

	ch := make(chan *dbus.Signal, 256)
	c.conn.Signal(ch)
	for sig := range ch {
		if sig.Name != "org.freedesktop.DBus.Properties.PropertiesChanged" {
			continue
		}
		if len(sig.Body) < 2 {
			continue
		}
		iface, _ := sig.Body[0].(string)
		if iface != "org.freedesktop.systemd1.Unit" {
			continue
		}
		changed, ok := sig.Body[1].(map[string]dbus.Variant)
		if !ok {
			continue
		}
		unit := unescapeUnit(filepath.Base(string(sig.Path)))
		c.handleUnitProps(unit, changed)
	}
}

func (c *CoreAura) handleUnitProps(unit string, changed map[string]dbus.Variant) {
	if !watchedUnits[unit] {
		return
	}
	svcMu.Lock()
	defer svcMu.Unlock()

	if v, ok := changed["ActiveState"]; ok {
		if newState, ok := v.Value().(string); ok {
			old := svcLastState[unit]
			svcLastState[unit] = newState
			if newState == "failed" && old != "failed" {
				c.logf("[service/%s] FAILED", unit)
				c.emit("ServiceStateChanged", unit, "failed")
			}
		}
	}
	if v, ok := changed["NRestarts"]; ok {
		var n uint32
		switch val := v.Value().(type) {
		case uint32:
			n = val
		case int32:
			n = uint32(val)
		case uint64:
			n = uint32(val)
		}
		prev := svcRestarts[unit]
		if n > prev {
			c.logf("[service/%s] restarted (+%d, total %d)", unit, n-prev, n)
			svcRestarts[unit] = n
			c.emit("ServiceStateChanged", unit, "restarted")
		}
	}
}

// ---------- resources ----------

type resourceSample struct {
	CPU       string  `json:"cpu"`
	CPUPct    float64 `json:"cpu_pct"`
	GPU       string  `json:"gpu"`
	GPUPct    float64 `json:"gpu_pct"`
	Timestamp int64   `json:"timestamp"`
	Initial   bool    `json:"initial,omitempty"`
}

// sampleResources делает один замер CPU (200 мс окно) + GPU.
// Возвращает idle/total для продолжения инкрементального подсчёта.
func sampleResources(cfg CoreAuraCfg) (resourceSample, uint64, uint64) {
	prevIdle, prevTotal, _ := readCPUUsage(0, 0)
	time.Sleep(200 * time.Millisecond)
	idle, total, cpuPct := readCPUUsage(prevIdle, prevTotal)

	gpuPct := readGPUUsage()
	cpuState, gpuState := classify(cpuPct, gpuPct, cfg)

	return resourceSample{
		CPU:       cpuState,
		CPUPct:    math.Round(cpuPct*10) / 10,
		GPU:       gpuState,
		GPUPct:    math.Round(gpuPct*10) / 10,
		Timestamp: time.Now().Unix(),
		Initial:   true,
	}, idle, total
}

func classify(cpuPct, gpuPct float64, cfg CoreAuraCfg) (string, string) {
	cpuState := "normal"
	if cpuPct > float64(cfg.CPUThresholdPercent) {
		cpuState = "overload"
	}
	gpuState := "normal"
	if gpuPct < 0 {
		gpuState = "unknown"
	} else if gpuPct > float64(cfg.GPUThresholdPercent) {
		gpuState = "overload"
	}
	return cpuState, gpuState
}

func marshalResource(s resourceSample) string {
	payload, _ := json.Marshal(s)
	return string(payload)
}

func readCPUUsage(prevIdle, prevTotal uint64) (uint64, uint64, float64) {
	data, err := os.ReadFile("/proc/stat")
	if err != nil {
		return prevIdle, prevTotal, 0
	}
	lines := strings.Split(string(data), "\n")
	if len(lines) == 0 {
		return prevIdle, prevTotal, 0
	}
	fields := strings.Fields(lines[0])
	if len(fields) < 5 || fields[0] != "cpu" {
		return prevIdle, prevTotal, 0
	}

	var vals []uint64
	for i := 1; i <= 8 && i < len(fields); i++ {
		v, _ := strconv.ParseUint(fields[i], 10, 64)
		vals = append(vals, v)
	}
	if len(vals) < 4 {
		return prevIdle, prevTotal, 0
	}

	idle := vals[3]
	if len(vals) > 4 {
		idle += vals[4]
	}
	var total uint64
	for _, v := range vals {
		total += v
	}

	var usage float64
	if prevTotal > 0 && total > prevTotal {
		dTotal := total - prevTotal
		dIdle := idle - prevIdle
		if dTotal > 0 {
			usage = 100.0 * float64(dTotal-dIdle) / float64(dTotal)
		}
	}
	return idle, total, usage
}

// nvidia-smi: путь кэшируем один раз, значение — на 2 секунды
var (
	nvidiaOnce   sync.Once
	nvidiaPath   string
	gpuCacheMu   sync.Mutex
	gpuCacheVal  float64
	gpuCacheTime time.Time
)

func readGPUUsage() float64 {
	cards, _ := filepath.Glob("/sys/class/drm/card*/device/gpu_busy_percent")
	for _, p := range cards {
		data, err := os.ReadFile(p)
		if err != nil {
			continue
		}
		val, err := strconv.Atoi(strings.TrimSpace(string(data)))
		if err == nil && val >= 0 {
			return float64(val)
		}
	}

	nvidiaOnce.Do(func() { nvidiaPath, _ = exec.LookPath("nvidia-smi") })
	if nvidiaPath == "" {
		return -1
	}

	gpuCacheMu.Lock()
	defer gpuCacheMu.Unlock()
	if time.Since(gpuCacheTime) < 2*time.Second {
		return gpuCacheVal
	}

	out, err := exec.Command(nvidiaPath,
		"--query-gpu=utilization.gpu",
		"--format=csv,noheader,nounits").Output()
	if err != nil {
		return gpuCacheVal // при сбое отдаём последнее известное, а не -1
	}
	line := strings.TrimSpace(string(out))
	if idx := strings.IndexByte(line, '\n'); idx >= 0 {
		line = line[:idx]
	}
	val, err := strconv.Atoi(strings.TrimSpace(line))
	if err != nil || val < 0 {
		return gpuCacheVal
	}
	gpuCacheVal = float64(val)
	gpuCacheTime = time.Now()
	return gpuCacheVal
}

func (c *CoreAura) resourceWatcher() {
	interval := time.Duration(c.cfg.ResourcePollIntervalSec) * time.Second
	c.logf("resource watcher: polling every %s (cpu>%d%% gpu>%d%%, dedup=%ds)",
		interval, c.cfg.CPUThresholdPercent, c.cfg.GPUThresholdPercent,
		c.cfg.DedupWindowSec)

	sample, prevIdle, prevTotal := sampleResources(c.cfg)
	c.logf("[resource] initial cpu=%s (%.1f%%) gpu=%s (%.1f%%)",
		sample.CPU, sample.CPUPct, sample.GPU, sample.GPUPct)
	c.emit("ResourceStatusChanged", marshalResource(sample))

	lastCPUState := sample.CPU
	lastGPUState := sample.GPU
	lastEmitTime := time.Now()
	overloadRepeat := 60 * time.Second

	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for range ticker.C {
		var u float64
		prevIdle, prevTotal, u = readCPUUsage(prevIdle, prevTotal)

		g := readGPUUsage()
		cs, gs := classify(u, g, c.cfg)

		stateChanged := cs != lastCPUState || gs != lastGPUState
		overloadRepeatDue := (cs == "overload" || gs == "overload") &&
			time.Since(lastEmitTime) > overloadRepeat

		if stateChanged || overloadRepeatDue {
			s := resourceSample{
				CPU:       cs,
				CPUPct:    math.Round(u*10) / 10,
				GPU:       gs,
				GPUPct:    math.Round(g*10) / 10,
				Timestamp: time.Now().Unix(),
			}
			c.logf("[resource] cpu=%s (%.1f%%) gpu=%s (%.1f%%)", cs, u, gs, g)
			c.emit("ResourceStatusChanged", marshalResource(s))
			lastCPUState = cs
			lastGPUState = gs
			lastEmitTime = time.Now()
		}
	}
}

// ---------- UI watcher ----------

func pidAlive(pid uint32) bool {
	if pid == 0 {
		return false
	}
	err := syscall.Kill(int(pid), 0)
	if err == nil {
		return true
	}
	return err == syscall.EPERM
}

func (c *CoreAura) uiPollLoop() {
	c.logf("ui watcher: polling every 2s")
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	for range ticker.C {
		// Один проход: один pidAlive на запись (было два)
		var dead []*UIEntry
		c.mu.Lock()
		for tok, e := range c.uis {
			if !pidAlive(e.PID) {
				dead = append(dead, e)
				delete(c.uis, tok)
			}
		}
		c.mu.Unlock()

		for _, e := range dead {
			c.logf("[ui] pid %d (uid %d) is dead", e.PID, e.UID)
			c.handleUICrash(e)
		}
	}
}

var (
	reLoaded   = regexp.MustCompile(`\[plugin\]\s*Загружен:\s*(\S+)`)
	reLoadFail = regexp.MustCompile(`\[plugin\]\s*Ошибка загрузки:\s*(\S+)`)
)

// tailFile читает только последние maxBytes файла вместо целиком.
func tailFile(path string, maxBytes int64) []byte {
	f, err := os.Open(path)
	if err != nil {
		return nil
	}
	defer f.Close()

	st, err := f.Stat()
	if err != nil {
		return nil
	}
	off := st.Size() - maxBytes
	if off < 0 {
		off = 0
	}
	if _, err := f.Seek(off, io.SeekStart); err != nil {
		return nil
	}
	data, err := io.ReadAll(f)
	if err != nil {
		return nil
	}
	if off > 0 {
		// Первая строка обрезана — отбрасываем её
		if idx := bytes.IndexByte(data, '\n'); idx >= 0 {
			data = data[idx+1:]
		} else {
			return nil
		}
	}
	return data
}

func findCulprit(logPath string, tailLines int) string {
	if logPath == "" {
		return ""
	}

	// 300 строк × ~1.7 КБ/строка с запасом — читаем хвост, а не весь лог
	const tailBytes = 512 * 1024

	try := func(p string) string {
		data := tailFile(p, tailBytes)
		if data == nil {
			return ""
		}
		lines := strings.Split(string(data), "\n")
		if len(lines) > tailLines {
			lines = lines[len(lines)-tailLines:]
		}
		for i := len(lines) - 1; i >= 0; i-- {
			if m := reLoadFail.FindStringSubmatch(lines[i]); m != nil {
				return strings.Trim(m[1], `"'`)
			}
		}
		var last string
		for _, l := range lines {
			if m := reLoaded.FindStringSubmatch(l); m != nil {
				last = strings.Trim(m[1], `"'`)
			}
		}
		return last
	}

	if c := try(logPath); c != "" {
		return c
	}
	if strings.HasSuffix(logPath, ".log") {
		return try(strings.TrimSuffix(logPath, ".log") + ".crash.log")
	}
	return ""
}

func lookupHome(uid uint32) string {
	u, err := user.LookupId(strconv.FormatUint(uint64(uid), 10))
	if err != nil {
		return ""
	}
	return u.HomeDir
}

func (c *CoreAura) blacklistAddFor(uid uint32, name string) {
	if name == "" {
		return
	}
	home := lookupHome(uid)
	if home == "" {
		c.logf("[blacklist] cannot resolve home for uid %d", uid)
		return
	}
	dir := filepath.Join(home, ".cache", "JES")
	path := filepath.Join(dir, "blacklist")

	if err := os.MkdirAll(dir, 0o755); err != nil {
		c.logf("[blacklist] mkdir %s: %v", dir, err)
		return
	}
	_ = os.Chown(dir, int(uid), -1)

	if b, err := os.ReadFile(path); err == nil {
		for _, l := range strings.Split(string(b), "\n") {
			if strings.TrimSpace(l) == name {
				return
			}
		}
	}

	f, err := os.OpenFile(path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
	if err != nil {
		c.logf("[blacklist] open %s: %v", path, err)
		return
	}
	defer f.Close()
	fmt.Fprintln(f, name)
	_ = os.Chown(path, int(uid), -1)
	c.logf("[blacklist] added for uid=%d: %s", uid, name)
}

func (c *CoreAura) handleUICrash(e *UIEntry) {
	culprit := findCulprit(e.LogPath, c.cfg.LogTailLines)
	if culprit != "" {
		c.logf("[ui] crash attributed to plugin: %s", culprit)
		c.blacklistAddFor(e.UID, culprit)
	} else {
		c.logf("[ui] crash: no plugin attributed")
	}
	c.emit("UICrashed", e.PID, e.UID, culprit)
}

// ---------- subscribe (client) ----------

func runSubscribe() {
	conn, err := getBus()
	if err != nil {
		fmt.Fprintln(os.Stderr, "bus:", err)
		os.Exit(1)
	}
	conn.AddMatchSignal(dbus.WithMatchSender(busName))
	ch := make(chan *dbus.Signal, 256)
	conn.Signal(ch)
	enc := json.NewEncoder(os.Stdout)
	for sig := range ch {
		if !strings.HasPrefix(sig.Name, busIFace+".") {
			continue
		}
		name := strings.TrimPrefix(sig.Name, busIFace+".")
		_ = enc.Encode(map[string]any{
			"signal": name,
			"body":   normalizeBody(sig.Body),
			"time":   time.Now().Unix(),
		})
	}
}

// ---------- client methods ----------

func callMethod(method string, args ...any) {
	conn, err := getBus()
	if err != nil {
		fmt.Fprintln(os.Stderr, "bus:", err)
		os.Exit(1)
	}
	obj := conn.Object(busName, dbus.ObjectPath(busPath))
	var result any
	call := obj.Call(busIFace+"."+method, 0, args...)
	if call.Err != nil {
		fmt.Fprintln(os.Stderr, call.Err)
		os.Exit(1)
	}
	if err := call.Store(&result); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if result != nil {
		// Строка уже содержит JSON — не оборачиваем повторно
		if s, ok := result.(string); ok {
			fmt.Println(s)
		} else {
			b, _ := json.Marshal(result)
			fmt.Println(string(b))
		}
	}
}

// ---------- main ----------

func main() {
	configPath := flag.String("config", "/etc/jes/coreaura.toml", "config file")
	flag.BoolVar(&useSessionBus, "session", false, "use session D-Bus instead of system")
	flag.Parse()

	args := flag.Args()
	cmd := "daemon"
	if len(args) > 0 {
		cmd = args[0]
		args = args[1:]
	}

	switch cmd {
	case "subscribe":
		runSubscribe()
		return
	case "register":
		if len(args) != 3 {
			fmt.Fprintln(os.Stderr, "usage: coreaura register <pid> <uid> <log>")
			os.Exit(1)
		}
		pid, _ := strconv.ParseUint(args[0], 10, 32)
		uid, _ := strconv.ParseUint(args[1], 10, 32)
		callMethod("RegisterUI", uint32(pid), uint32(uid), args[2])
		return
	case "unregister":
		if len(args) != 1 {
			fmt.Fprintln(os.Stderr, "usage: coreaura unregister <token>")
			os.Exit(1)
		}
		callMethod("UnregisterUI", args[0])
		return
	case "status":
		callMethod("GetStatus")
		return
	case "resources":
		callMethod("GetResourceStatus")
		return
	case "daemon":
	default:
		fmt.Fprintln(os.Stderr, "unknown command:", cmd)
		os.Exit(1)
	}

	// --- daemon mode ---
	var cfg Config
	if _, err := toml.DecodeFile(*configPath, &cfg); err != nil {
		fmt.Fprintln(os.Stderr, "config:", err)
		os.Exit(1)
	}
	ca := cfg.CoreAura
	if ca.KernelPriorityMax == 0 {
		ca.KernelPriorityMax = 3
	}
	if ca.LogTailLines == 0 {
		ca.LogTailLines = 300
	}
	if ca.ResourcePollIntervalSec == 0 {
		ca.ResourcePollIntervalSec = 5
	}
	if ca.CPUThresholdPercent == 0 {
		ca.CPUThresholdPercent = 85
	}
	if ca.GPUThresholdPercent == 0 {
		ca.GPUThresholdPercent = 85
	}
	if ca.DedupWindowSec == 0 {
		ca.DedupWindowSec = 30
	}

	conn, err := getBus()
	if err != nil {
		fmt.Fprintln(os.Stderr, "bus:", err)
		os.Exit(1)
	}

	svc := &CoreAura{
		conn:     conn,
		cfg:      ca,
		uis:      map[string]*UIEntry{},
		dedupMap: map[string]*dedupEntry{},
	}

	if err := conn.Export(svc, dbus.ObjectPath(busPath), busIFace); err != nil {
		fmt.Fprintln(os.Stderr, "export:", err)
		os.Exit(1)
	}
	reply, err := conn.RequestName(busName, dbus.NameFlagDoNotQueue)
	if err != nil {
		fmt.Fprintln(os.Stderr, "RequestName:", err)
		os.Exit(1)
	}
	if reply != dbus.RequestNameReplyPrimaryOwner {
		fmt.Fprintln(os.Stderr, "name already taken")
		os.Exit(1)
	}

	if ca.Enabled {
		go svc.kernelWatcher()
		go svc.systemdWatcher()
		go svc.uiPollLoop()
		go svc.resourceWatcher()
	} else {
		svc.logf("CoreAura: monitoring disabled in config")
	}

	svc.logf("CoreAura started on %s (bus=%s, kernel<=%d, services=%v, enabled=%v, dedup=%ds)",
		busName,
		map[bool]string{true: "session", false: "system"}[useSessionBus],
		ca.KernelPriorityMax, ca.Services, ca.Enabled, ca.DedupWindowSec)

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	<-sig
	svc.logf("CoreAura stopped")
}
