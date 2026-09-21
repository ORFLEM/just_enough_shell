package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/godbus/dbus/v5"
)

type Output struct {
	Artist string `json:"artist"`
	Title  string `json:"title"`
	Art    string `json:"art"`
	Status string `json:"status"`
	Player string `json:"player"`
	Ver    int64  `json:"ver"`
}

type playerInfo struct {
	name   string
	status string
}

var (
	cacheMutex     sync.Mutex
	cachedFile     string
	lastArtPath    string
	lastURL        string
	defaultArt     string
	customCacheDir string
	lastArtVer     int64

	// Последние непустые метаданные — против Chromium-гонки,
	// когда при Playing прилетают пустые title/artist
	lastMetaPlayer string
	lastTitle      string
	lastArtist     string
)

func init() {
	homeDir, _ := os.UserHomeDir()
	cacheDir, _ := os.UserCacheDir()

	customCacheDir = filepath.Join(cacheDir, "JES", "jes_music_art")
	_ = os.MkdirAll(customCacheDir, 0755)

	appDir := filepath.Join(cacheDir, "music-daemon")
	_ = os.MkdirAll(appDir, 0755)

	cachedFile = filepath.Join(appDir, "state.json")
	defaultArt = filepath.Join(homeDir, ".local/JES/quickshell/bar/images/music.webp")
	lastArtVer = time.Now().UnixMilli()
}

func getCachedPlayer() string {
	cacheMutex.Lock()
	defer cacheMutex.Unlock()

	data, err := os.ReadFile(cachedFile)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func setCachedPlayer(name string) {
	cacheMutex.Lock()
	defer cacheMutex.Unlock()
	_ = os.WriteFile(cachedFile, []byte(name), 0644)
}

func getMprisPlayers(conn *dbus.Conn) []string {
	var names []string
	err := conn.BusObject().Call("org.freedesktop.DBus.ListNames", 0).Store(&names)
	if err != nil {
		return nil
	}

	var players []string
	for _, name := range names {
		if strings.HasPrefix(name, "org.mpris.MediaPlayer2.") {
			players = append(players, strings.TrimPrefix(name, "org.mpris.MediaPlayer2."))
		}
	}
	return players
}

// getPlaybackStatus возвращает статус плеера и факт его живости на шине
func getPlaybackStatus(conn *dbus.Conn, player string) (string, bool) {
	obj := conn.Object("org.mpris.MediaPlayer2."+player, "/org/mpris/MediaPlayer2")
	statusVal, err := obj.GetProperty("org.mpris.MediaPlayer2.Player.PlaybackStatus")
	if err != nil {
		return "", false
	}
	status, ok := statusVal.Value().(string)
	return status, ok
}

// getPlayerInfos возвращает только живых плееров, не находящихся
// в Stopped: завершивший проигрывание Telegram снимает статус,
// но НЕ снимает имя с шины — без фильтра он висит на баре вечно.
func getPlayerInfos(conn *dbus.Conn) []playerInfo {
	var infos []playerInfo
	for _, p := range getMprisPlayers(conn) {
		if status, ok := getPlaybackStatus(conn, p); ok && status != "Stopped" {
			infos = append(infos, playerInfo{name: p, status: status})
		}
	}
	return infos
}

func playerAlive(conn *dbus.Conn, player string) bool {
	_, ok := getPlaybackStatus(conn, player)
	return ok
}

func resolveFallbackArt() string {
	cacheArt := filepath.Join(customCacheDir, "current.png")
	if _, err := os.Stat(cacheArt); err == nil {
		return cacheArt
	}
	return defaultArt
}

func processArt(artURL string) (string, bool) {
	if artURL == "" {
		fallback := resolveFallbackArt()
		return fallback, fallback != lastArtPath
	}

	if strings.HasPrefix(artURL, "data:image/") {
		if artURL == lastURL {
			return lastArtPath, false
		}

		idx := strings.Index(artURL, ",")
		if idx != -1 {
			base64Data := artURL[idx+1:]
			decoded, err := base64.StdEncoding.DecodeString(base64Data)
			if err == nil {
				tmpPath := filepath.Join(customCacheDir, "cover.img")
				if err := os.WriteFile(tmpPath, decoded, 0644); err == nil {
					return tmpPath, true
				}
			}
		}

		fallback := resolveFallbackArt()
		return fallback, fallback != lastArtPath
	}

	if strings.HasPrefix(artURL, "file://") {
		path := artURL
		u, err := url.Parse(artURL)
		if err == nil {
			path = u.Path
		} else {
			path = strings.TrimPrefix(artURL, "file://")
		}

		if _, err := os.Stat(path); err == nil {
			if path != lastArtPath {
				return path, true
			}
			return lastArtPath, false
		}

		fallback := resolveFallbackArt()
		return fallback, fallback != lastArtPath
	}

	if _, err := os.Stat(artURL); err == nil {
		if artURL != lastArtPath {
			return artURL, true
		}
		return lastArtPath, false
	}

	if strings.HasPrefix(artURL, "http://") || strings.HasPrefix(artURL, "https://") {
		if artURL == lastURL {
			return lastArtPath, false
		}

		tmpPath := filepath.Join(customCacheDir, "cover.img")

		cmd := exec.Command("curl", "-s", "-o", tmpPath, artURL)
		if err := cmd.Run(); err == nil {
			return tmpPath, true
		}

		fallback := resolveFallbackArt()
		return fallback, fallback != lastArtPath
	}

	fallback := resolveFallbackArt()
	return fallback, fallback != lastArtPath
}

func emit(out Output) {
	bytes, _ := json.Marshal(out)
	fmt.Println(string(bytes))
}

func emitNoMedia() {
	setCachedPlayer("")
	fallback := resolveFallbackArt()
	emit(Output{
		Title:  "No media",
		Art:    fallback,
		Status: "󰐊",
		Player: "",
		Ver:    lastArtVer,
	})
}

func fetchAndEmit(conn *dbus.Conn) {
	// Отсекаем мёртвые и остановленные имена сразу: Chromium снимает
	// имя с шины раньше, чем ListNames обновляется (гонка), а Telegram
	// остаётся на шине в Stopped после конца трека. Такие плееры
	// не должны попадать ни в выбор, ни в отображение.
	infos := getPlayerInfos(conn)

	if len(infos) == 0 {
		emitNoMedia()
		return
	}

	currP := getCachedPlayer()

	// Приоритет: кто играет — тот и главный
	var activePlaying string
	for _, info := range infos {
		if info.status == "Playing" {
			activePlaying = info.name
			break
		}
	}

	if activePlaying != "" {
		if activePlaying != currP {
			currP = activePlaying
			setCachedPlayer(currP)
		}
	} else {
		found := false
		for _, info := range infos {
			if info.name == currP {
				found = true
				break
			}
		}
		if !found {
			currP = infos[0].name
			setCachedPlayer(currP)
		}
	}

	busName := "org.mpris.MediaPlayer2." + currP
	obj := conn.Object(busName, "/org/mpris/MediaPlayer2")

	status := ""
	for _, info := range infos {
		if info.name == currP {
			status = info.status
			break
		}
	}

	icon := "󰐊"
	if status == "Playing" {
		icon = "󰏤"
	}

	metaVal, err := obj.GetProperty("org.mpris.MediaPlayer2.Player.Metadata")
	var artist, title, artURL string
	if err == nil {
		if metaMap, ok := metaVal.Value().(map[string]dbus.Variant); ok {
			if titleVar, ok := metaMap["xesam:title"]; ok {
				title, _ = titleVar.Value().(string)
			}
			if artistVar, ok := metaMap["xesam:artist"]; ok {
				if artistSlice, ok := artistVar.Value().([]string); ok && len(artistSlice) > 0 {
					artist = artistSlice[0]
				} else if aStr, ok := artistVar.Value().(string); ok {
					artist = aStr
				}
			}
			if artVar, ok := metaMap["mpris:artUrl"]; ok {
				artURL, _ = artVar.Value().(string)
			}
		}
	}

	// Chromium-гонка: при Playing иногда прилетают пустые метаданные
	// поверх валидных. Плеер играет и трек не менялся — не затираем.
	if status == "Playing" && currP == lastMetaPlayer {
		if title == "" {
			title = lastTitle
		}
		if artist == "" {
			artist = lastArtist
		}
		if artURL == "" {
			artURL = lastURL
		}
	}

	artPath, artChanged := processArt(artURL)
	if artChanged {
		lastArtPath = artPath
		lastURL = artURL
		lastArtVer = time.Now().UnixMilli()
	}

	lastMetaPlayer = currP
	lastTitle = title
	lastArtist = artist

	cleanPlayerName := currP
	if idx := strings.Index(cleanPlayerName, "."); idx != -1 {
		cleanPlayerName = cleanPlayerName[:idx]
	}

	emit(Output{
		Artist: artist,
		Title:  title,
		Art:    artPath,
		Status: icon,
		Player: cleanPlayerName,
		Ver:    lastArtVer,
	})
}

func runCLI(conn *dbus.Conn, cmd string) {
	// Только живые и не остановленные — иначе можно переключиться
	// на зависшего в Stopped Telegram
	var players []string
	for _, info := range getPlayerInfos(conn) {
		players = append(players, info.name)
	}
	curr := getCachedPlayer()

	switch cmd {
	case "next-player":
		if len(players) <= 1 {
			return
		}
		idx := -1
		for i, p := range players {
			if p == curr {
				idx = i
				break
			}
		}
		nextIdx := (idx + 1) % len(players)
		setCachedPlayer(players[nextIdx])
		notifyPlayerSwitched(conn)

	case "prev-player":
		if len(players) <= 1 {
			return
		}
		idx := -1
		for i, p := range players {
			if p == curr {
				idx = i
				break
			}
		}
		prevIdx := (idx - 1 + len(players)) % len(players)
		setCachedPlayer(players[prevIdx])
		notifyPlayerSwitched(conn)

	case "play-pause", "next", "previous":
		if curr == "" {
			return
		}
		// Если кэш протух — команда уйдёт в никуда, попробуем поднять живого
		if !playerAlive(conn, curr) {
			for _, p := range players {
				if p != curr && playerAlive(conn, p) {
					curr = p
					setCachedPlayer(curr)
					break
				}
			}
		}
		if curr == "" || !playerAlive(conn, curr) {
			return
		}
		busName := "org.mpris.MediaPlayer2." + curr
		obj := conn.Object(busName, "/org/mpris/MediaPlayer2")

		m := map[string]string{
			"play-pause": "PlayPause",
			"next":       "Next",
			"previous":   "Previous",
		}[cmd]

		obj.Call("org.mpris.MediaPlayer2.Player."+m, 0)
	}
}

func notifyPlayerSwitched(conn *dbus.Conn) {
	_ = conn.Emit("/org/jes/Music", "org.jes.Music.PlayerSwitched")
}

func runDaemon(conn *dbus.Conn) {
	// 1. Блокировка повторного запуска через забор DBus-имени
	reply, err := conn.RequestName("org.jes.Music", dbus.NameFlagDoNotQueue)
	if err != nil || reply != dbus.RequestNameReplyPrimaryOwner {
		// Демон уже запущен в системе, тихо завершаем дубликат
		os.Exit(0)
	}

	// 2. Слушаем события СТРОГО на MPRIS-объектах
	ruleProp := "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'"
	conn.BusObject().Call("org.freedesktop.DBus.AddMatch", 0, ruleProp)

	ruleSwitch := "type='signal',interface='org.jes.Music',member='PlayerSwitched'"
	conn.BusObject().Call("org.freedesktop.DBus.AddMatch", 0, ruleSwitch)

	// 3. Chromium (и др. динамические плееры) снимают/вешают MPRIS-имя
	//    без PropertiesChanged — трекаем появление и исчезновение имён.
	ruleNames := "type='signal',sender='org.freedesktop.DBus',interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0namespace='org.mpris.MediaPlayer2.'"
	conn.BusObject().Call("org.freedesktop.DBus.AddMatch", 0, ruleNames)

	ch := make(chan *dbus.Signal, 10)
	conn.Signal(ch)

	fetchAndEmit(conn)

	// 4. Debounce-механизм (не чаще одного раза в 50мс)
	var timer *time.Timer
	var mu sync.Mutex

	trigger := make(chan struct{}, 1)
	go func() {
		for range trigger {
			fetchAndEmit(conn)
		}
	}()

	for range ch {
		mu.Lock()
		if timer != nil {
			timer.Stop()
		}
		timer = time.AfterFunc(50*time.Millisecond, func() {
			select {
			case trigger <- struct{}{}:
			default:
			}
		})
		mu.Unlock()
	}
}

func main() {
	conn, err := dbus.ConnectSessionBus()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to connect to session bus: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close()

	if len(os.Args) > 1 {
		runCLI(conn, os.Args[1])
	} else {
		runDaemon(conn)
	}
}
