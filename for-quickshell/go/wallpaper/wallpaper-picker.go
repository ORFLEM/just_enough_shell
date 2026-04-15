package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"github.com/BurntSushi/toml"
)

// ─── Конфиг ─────────────────────────────────────────────────────────────────

type Config struct {
	Dirs  DirsConfig  `toml:"dirs"`
	State StateConfig `toml:"state"`
}

type DirsConfig struct {
	ImageDirs []string `toml:"image_dirs"`
	VideoDirs []string `toml:"video_dirs"`
	ShaderDir string   `toml:"shader_dir"`
}

type StateConfig struct {
	Mode      string `toml:"mode"`      // "image" | "video" | "shader"
	Wallpaper string `toml:"wallpaper"`
	Shader    string `toml:"shader"`
}

var configPath = homeDir(".config/quickshell/wallpaper/wallpaper.toml")

func homeDir(rel string) string {
	h, _ := os.UserHomeDir()
	return filepath.Join(h, rel)
}

func expandHome(p string) string {
	if strings.HasPrefix(p, "~/") {
		return filepath.Join(homeDir(""), p[2:])
	}
	return p
}

func loadConfig() Config {
	var cfg Config
	if _, err := toml.DecodeFile(configPath, &cfg); err != nil {
		fmt.Fprintf(os.Stderr, "[wp] config error: %v\n", err)
		return cfg
	}
	for i, d := range cfg.Dirs.ImageDirs {
		cfg.Dirs.ImageDirs[i] = expandHome(d)
	}
	for i, d := range cfg.Dirs.VideoDirs {
		cfg.Dirs.VideoDirs[i] = expandHome(d)
	}
	cfg.Dirs.ShaderDir = expandHome(cfg.Dirs.ShaderDir)
	cfg.State.Wallpaper = expandHome(cfg.State.Wallpaper)
	return cfg
}

func saveState(mode, wallpaper, shader string) {
	data, err := os.ReadFile(configPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "[wp] saveState read: %v\n", err)
		return
	}
	newState := fmt.Sprintf("[state]\nmode      = %q\nwallpaper = %q\nshader    = %q\n",
		mode, wallpaper, shader)
	content := string(data)
	if idx := strings.Index(content, "\n[state]"); idx != -1 {
		content = content[:idx+1] + newState
	} else if idx := strings.Index(content, "[state]"); idx != -1 {
		content = content[:idx] + newState
	} else {
		content += "\n" + newState
	}
	if err := os.WriteFile(configPath, []byte(content), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "[wp] saveState write: %v\n", err)
	}
}

// ─── Кэш ────────────────────────────────────────────────────────────────────

var (
	cacheDir    = homeDir(".cache/walls")
	previewDir  = homeDir(".cache/wall_prevs")
	staticCache = filepath.Join(cacheDir, "no-live-bg.jpg")
	videoCache  = filepath.Join(cacheDir, "live-bg.mp4")
	videoFrame  = filepath.Join(cacheDir, "video-frame.jpg")
)

// ─── Типы ────────────────────────────────────────────────────────────────────

type WallEntry struct {
	Path  string `json:"path"`
	Name  string `json:"name"`
	Type  string `json:"type"` // "image" | "video" | "shader"
	Thumb string `json:"thumb"`
}

type StateJSON struct {
	Mode     string `json:"mode"`
	Wallpaper string `json:"wallpaper"`
	Shader   string `json:"shader"`
	WallType int    `json:"wallType"` // 1=image 2=shader 3=video
}

func modeToWallType(mode string) int {
	switch mode {
	case "image":  return 1
	case "shader": return 2
	case "video":  return 3
	}
	return 1
}

// ─── Сбор файлов ─────────────────────────────────────────────────────────────

func thumbName(path string) string {
	h := uint32(5381)
	for _, c := range path {
		h = h*33 + uint32(c)
	}
	return fmt.Sprintf("thumb_%08x.jpg", h)
}

func collectByDirs(dirs []string, exts map[string]bool, kind string) []WallEntry {
	var entries []WallEntry
	for _, dir := range dirs {
		des, err := os.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, de := range des {
			if de.IsDir() {
				continue
			}
			ext := strings.ToLower(filepath.Ext(de.Name()))
			if !exts[ext] {
				continue
			}
			fullPath := filepath.Join(dir, de.Name())
			entries = append(entries, WallEntry{
				Path:  fullPath,
				Name:  de.Name(),
				Type:  kind,
				Thumb: filepath.Join(previewDir, thumbName(fullPath)),
			})
		}
	}
	return entries
}

func collectShaders(dir string) []WallEntry {
	var entries []WallEntry
	des, err := os.ReadDir(dir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "[wp] shader dir not found: %s: %v\n", dir, err)
		return entries
	}

	// Дедупликация: один шейдер может присутствовать и как .frag и как .qsb
	// Показываем каждое имя только один раз
	seen := map[string]bool{}

	for _, de := range des {
		if de.IsDir() {
			continue
		}
		ext := strings.ToLower(filepath.Ext(de.Name()))
		if ext != ".frag" && ext != ".qsb" {
			continue
		}

		// Стрипаем все расширения: bg.frag.qsb → bg
		name := de.Name()
		for {
			stripped := strings.TrimSuffix(name, filepath.Ext(name))
			if stripped == name {
				break
			}
			name = stripped
		}

		if seen[name] {
			continue
		}
		seen[name] = true

		fullPath := filepath.Join(dir, de.Name())
		entries = append(entries, WallEntry{
			Path:  fullPath,
			Name:  name,
			Type:  "shader",
			Thumb: "",
		})
	}
	return entries
}

// ─── Команды ─────────────────────────────────────────────────────────────────

// list-tab <tab> [search]
// tab: "image" | "video" | "shader"
// Вся фильтрация здесь — QML получает готовый список
func cmdListTab(tab, search string) {
	cfg := loadConfig()
	search = strings.ToLower(strings.TrimSpace(search))

	var entries []WallEntry

	switch tab {
	case "image":
		entries = collectByDirs(cfg.Dirs.ImageDirs, map[string]bool{
			".jpg": true, ".jpeg": true, ".png": true, ".webp": true,
		}, "image")
	case "video":
		entries = collectByDirs(cfg.Dirs.VideoDirs, map[string]bool{
			".mp4": true, ".webm": true, ".mkv": true,
		}, "video")
	case "shader":
		entries = collectShaders(cfg.Dirs.ShaderDir)
	}

	// Фильтрация на стороне Go — QML не делает ничего
	if search != "" {
		filtered := entries[:0]
		for _, e := range entries {
			if strings.Contains(strings.ToLower(e.Name), search) {
				filtered = append(filtered, e)
			}
		}
		entries = filtered
	}

	if entries == nil {
		entries = []WallEntry{}
	}

	out, _ := json.Marshal(entries)
	fmt.Println(string(out))
}

// get-state — восстановление при старте quickshell
func cmdGetState() {
	cfg := loadConfig()
	s := StateJSON{
		Mode:      cfg.State.Mode,
		Wallpaper: cfg.State.Wallpaper,
		Shader:    cfg.State.Shader,
		WallType:  modeToWallType(cfg.State.Mode),
	}
	out, _ := json.Marshal(s)
	fmt.Println(string(out))
}

// cache-all — генерирует превью для всех обоев параллельно
func cmdCacheAll() {
	cfg := loadConfig()
	os.MkdirAll(previewDir, 0755)

	imageExts := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".webp": true}
	videoExts := map[string]bool{".mp4": true, ".webm": true, ".mkv": true}
	all := append(
		collectByDirs(cfg.Dirs.ImageDirs, imageExts, "image"),
		collectByDirs(cfg.Dirs.VideoDirs, videoExts, "video")...,
	)

	var wg sync.WaitGroup
	sem := make(chan struct{}, 6)

	for _, e := range all {
		if _, err := os.Stat(e.Thumb); err == nil {
			continue
		}
		wg.Add(1)
		go func(entry WallEntry) {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			var cmd *exec.Cmd
			if entry.Type == "video" {
				cmd = exec.Command("ffmpeg",
					"-ss", "00:00:02", "-i", entry.Path,
					"-vframes", "1", "-vf", "scale=320:-1", "-q:v", "4",
					entry.Thumb, "-y")
			} else {
				cmd = exec.Command("ffmpeg",
					"-i", entry.Path,
					"-vf", "scale=320:-1", "-q:v", "4",
					entry.Thumb, "-y")
			}
			cmd.Stderr = nil
			_ = cmd.Run()
		}(e)
	}
	wg.Wait()
	fmt.Println("done")
}

func cmdCleanCache() {
	os.RemoveAll(previewDir)
	os.MkdirAll(previewDir, 0755)
	fmt.Println("done")
}

func cmdSet(path string) {
	if _, err := os.Stat(path); err != nil {
		fmt.Fprintln(os.Stderr, "file not found:", path)
		os.Exit(1)
	}

	ext := strings.ToLower(filepath.Ext(path))
	isVideo := ext == ".mp4" || ext == ".webm" || ext == ".mkv"
	os.MkdirAll(cacheDir, 0755)
	cfg := loadConfig()

	if isVideo {
		if err := copyFile(path, videoCache); err != nil {
			fmt.Fprintln(os.Stderr, "copy failed:", err)
			os.Exit(1)
		}
		exec.Command("ffmpeg",
			"-ss", "00:00:02", "-i", videoCache,
			"-vframes", "1", "-vf", "scale=1920:-1", "-q:v", "2",
			videoFrame, "-y").Run()
		exec.Command("qs", "ipc", "call", "root", "wallType", "4").Run()
		exec.Command("qs", "ipc", "call", "root", "wallType", "3").Run()
		if _, err := os.Stat(videoFrame); err == nil {
			exec.Command("wallust", "-s", "run", videoFrame).Run()
		}
		saveState("video", path, cfg.State.Shader)
	} else {
		out, _ := exec.Command("ffprobe",
			"-v", "error", "-select_streams", "v:0",
			"-show_entries", "stream=width", "-of", "csv=p=0", path).Output()
		width := 0
		fmt.Sscanf(strings.TrimSpace(string(out)), "%d", &width)
		if width > 3840 {
			exec.Command("ffmpeg",
				"-i", path, "-vf", "scale=3440:-1", "-q:v", "2",
				staticCache, "-y").Run()
		} else {
			if err := copyFile(path, staticCache); err != nil {
				fmt.Fprintln(os.Stderr, "copy failed:", err)
				os.Exit(1)
			}
		}
		exec.Command("pkill", "-x", "swaybg").Run()
		exec.Command("qs", "ipc", "call", "root", "wallType", "1").Run()
		exec.Command("wallust", "-s", "run", staticCache).Run()
		saveState("image", path, cfg.State.Shader)
	}
}

func cmdSetShader(name string) {
	cfg := loadConfig()
	exec.Command("qs", "ipc", "call", "root", "wallType", "2").Run()
	exec.Command("qs", "ipc", "call", "root", "wallShader", name).Run()
	saveState("shader", cfg.State.Wallpaper, name)
}

// ─── Утилиты ─────────────────────────────────────────────────────────────────

func copyFile(src, dst string) error {
	data, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	return os.WriteFile(dst, data, 0644)
}

// ─── Main ─────────────────────────────────────────────────────────────────────

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: wallpaper-picker <list-tab <tab> [search]|get-state|cache-all|clean-cache|set <path>|set-shader <name>>")
		os.Exit(1)
	}

	switch os.Args[1] {

	case "list-tab":
		// list-tab image
		// list-tab image "some search"
		tab := ""
		if len(os.Args) >= 3 {
			tab = os.Args[2]
		}
		search := ""
		if len(os.Args) >= 4 {
			search = os.Args[3]
		}
		cmdListTab(tab, search)

	case "get-state":
		cmdGetState()

	case "cache-all":
		cmdCacheAll()

	case "clean-cache":
		cmdCleanCache()

	case "set":
		if len(os.Args) < 3 {
			fmt.Fprintln(os.Stderr, "set requires <path>")
			os.Exit(1)
		}
		cmdSet(os.Args[2])

	case "set-shader":
		if len(os.Args) < 3 {
			fmt.Fprintln(os.Stderr, "set-shader requires <name>")
			os.Exit(1)
		}
		cmdSetShader(os.Args[2])

	default:
		fmt.Fprintln(os.Stderr, "unknown command:", os.Args[1])
		os.Exit(1)
	}
}
