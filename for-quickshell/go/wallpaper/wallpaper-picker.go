package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"bytes"
	"strconv" // добавлен

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
	Mode        string `toml:"mode"`        // "image" | "video" | "shader"
	Wallpaper   string `toml:"wallpaper"`
	Shader      string `toml:"shader"`
	ColorScheme string `toml:"colorscheme"`
}

var configPath = homeDir(".config/JES/wallpaper.toml")

// Глобальная переменная для текущей цветовой схемы
var currentColorScheme string

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
	if cfg.State.ColorScheme != "" {
		currentColorScheme = cfg.State.ColorScheme
	} else {
		currentColorScheme = "scheme-tonal-spot"
	}
	return cfg
}

func saveState(mode, wallpaper, shader, colorscheme string) {
	data, err := os.ReadFile(configPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "[wp] saveState read: %v\n", err)
		return
	}
	newState := fmt.Sprintf("[state]\nmode      = %q\nwallpaper = %q\nshader    = %q\ncolorscheme = %q\n",
		mode, wallpaper, shader, colorscheme)
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
	cacheDir    = homeDir(".cache/JES/walls")
	previewDir  = homeDir(".cache/JES/wall_prevs")
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
	Mode        string `json:"mode"`
	Wallpaper   string `json:"wallpaper"`
	Shader      string `json:"shader"`
	WallType    int    `json:"wallType"`
	ColorScheme string `json:"colorscheme"` // добавлено
}

func modeToWallType(mode string) int {
	switch mode {
	case "image":
		return 1
	case "shader":
		return 2
	case "video":
		return 3
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

	seen := map[string]bool{}

	for _, de := range des {
		if de.IsDir() {
			continue
		}
		ext := strings.ToLower(filepath.Ext(de.Name()))
		if ext != ".frag" && ext != ".qsb" {
			continue
		}

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

func detectImageType(path string) (realType string, isJPEG bool) {
	f, err := os.Open(path)
	if err != nil {
		return "unknown", false
	}
	defer f.Close()

	buf := make([]byte, 12)
	n, _ := f.Read(buf)
	if n < 4 {
		return "too_small", false
	}
	data := buf[:n]

	if bytes.HasPrefix(data, []byte{0xFF, 0xD8}) {
		return "jpeg", true
	}
	if bytes.HasPrefix(data, []byte{0x89, 0x50, 0x4E, 0x47}) {
		return "png", false
	}
	if n >= 12 && bytes.HasPrefix(data, []byte("RIFF")) && bytes.HasPrefix(data[8:], []byte("WEBP")) {
		return "webp", false
	}
	return "unknown", false
}

func ensureJPEG(path string, overwriteOriginal bool) (string, error) {
	_, isJPEG := detectImageType(path)
	if isJPEG && overwriteOriginal {
		return path, nil
	}
	if isJPEG && !overwriteOriginal {
		return path, nil
	}

	dir := filepath.Dir(path)
	base := strings.TrimSuffix(filepath.Base(path), filepath.Ext(path))
	var outputPath string

	if overwriteOriginal {
		outputPath = filepath.Join(dir, base+".jpg")
	} else {
		outputPath = filepath.Join(dir, base+".fixed.jpg")
	}

	tmpFile, err := os.CreateTemp(dir, "tmp_fix_*.jpg")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %w", err)
	}
	tmpPath := tmpFile.Name()
	tmpFile.Close()
	defer os.Remove(tmpPath)

	cmd := exec.Command("ffmpeg", "-i", path, "-q:v", "2", "-y", tmpPath)
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("ffmpeg conversion failed: %w", err)
	}

	if overwriteOriginal {
		if path != outputPath {
			if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
				return "", fmt.Errorf("failed to remove original: %w", err)
			}
		}
		if err := os.Rename(tmpPath, outputPath); err != nil {
			data, err := os.ReadFile(tmpPath)
			if err != nil {
				return "", err
			}
			if err := os.WriteFile(outputPath, data, 0644); err != nil {
				return "", err
			}
		}
		return outputPath, nil
	} else {
		if err := os.Rename(tmpPath, outputPath); err != nil {
			data, err := os.ReadFile(tmpPath)
			if err != nil {
				return "", err
			}
			if err := os.WriteFile(outputPath, data, 0644); err != nil {
				return "", err
			}
		}
		return outputPath, nil
	}
}

// ─── Команды ─────────────────────────────────────────────────────────────────

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

func cmdFixWalls() {
	cfg := loadConfig()
	allExts := map[string]bool{
		".jpg": true, ".jpeg": true, ".png": true, ".webp": true,
	}
	entries := collectByDirs(cfg.Dirs.ImageDirs, allExts, "image")

	var wg sync.WaitGroup
	sem := make(chan struct{}, 4)

	for _, e := range entries {
		wg.Add(1)
		go func(path string) {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()

			realType, isJPEG := detectImageType(path)
			ext := strings.ToLower(filepath.Ext(path))

			needFix := !isJPEG || (ext != ".jpg" && ext != ".jpeg")

			if needFix && (realType == "png" || realType == "webp" || realType == "jpeg") {
				fmt.Printf("Fixing %s (real: %s, ext: %s) -> converting to .jpg\n", path, realType, ext)
				newPath, err := ensureJPEG(path, true)
				if err != nil {
					fmt.Fprintf(os.Stderr, "Failed to fix %s: %v\n", path, err)
				} else {
					fmt.Printf("Fixed: %s -> %s\n", path, newPath)
				}
			} else if isJPEG && (ext == ".jpg" || ext == ".jpeg") {
				// уже JPEG
			} else {
				fmt.Fprintf(os.Stderr, "Skipping %s: unsupported real type %s\n", path, realType)
			}
		}(e.Path)
	}
	wg.Wait()
	fmt.Println("fix-walls completed")
}

// get-state — возвращает текущее состояние, включая colorscheme
func cmdGetState() {
	cfg := loadConfig()
	s := StateJSON{
		Mode:        cfg.State.Mode,
		Wallpaper:   cfg.State.Wallpaper,
		Shader:      cfg.State.Shader,
		WallType:    modeToWallType(cfg.State.Mode),
		ColorScheme: currentColorScheme, // теперь возвращаем
	}
	out, _ := json.Marshal(s)
	fmt.Println(string(out))
}

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

// applyMatugen применяет цветовую схему к imagePath.
// double == false: только один вызов с -c ~/.local/JES/matugen/config.toml
// double == true:  сначала с -c, затем без -c (как было раньше)
func applyMatugen(imagePath string, double bool) {
	if imagePath == "" {
		return
	}
	configPath := homeDir(".local/JES/matugen/config.toml")
	baseArgs := []string{"image", imagePath, "-m", "dark", "-t", currentColorScheme, "--source-color-index", "0"}

	// Первый вызов — всегда с конфигом
	argsWithConfig := append(baseArgs, "-c", configPath)
	cmd1 := exec.Command("matugen", argsWithConfig...)
	if err := cmd1.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "[wp] matugen with config failed: %v\n", err)
	}

	if double {
		// Второй вызов — без конфига
		cmd2 := exec.Command("matugen", baseArgs...)
		if err := cmd2.Run(); err != nil {
			fmt.Fprintf(os.Stderr, "[wp] matugen without config failed: %v\n", err)
		}
	}
}

func cmdSet(path string, double bool) {
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
		exec.Command("jes-cli", "wallType", "4").Run()
		exec.Command("jes-cli", "wallType", "3").Run()
		if _, err := os.Stat(videoFrame); err == nil {
			applyMatugen(videoFrame, double)
		}
		saveState("video", path, cfg.State.Shader, currentColorScheme)
	} else {
		fixedPath, err := ensureJPEG(path, false)
		if err != nil {
			fmt.Fprintln(os.Stderr, "fixing image failed:", err)
			os.Exit(1)
		}

		out, _ := exec.Command("ffprobe",
			"-v", "error", "-select_streams", "v:0",
			"-show_entries", "stream=width", "-of", "csv=p=0", fixedPath).Output()
		width := 0
		fmt.Sscanf(strings.TrimSpace(string(out)), "%d", &width)

		if width > 3840 {
			exec.Command("ffmpeg",
				"-i", fixedPath, "-vf", "scale=3440:-1", "-q:v", "2",
				staticCache, "-y").Run()
		} else {
			copyFile(fixedPath, staticCache)
		}
		exec.Command("jes-cli", "wallType", "1").Run()
		applyMatugen(staticCache, double)
		saveState("image", path, cfg.State.Shader, currentColorScheme)
	}
}

func cmdSetShader(name string, double bool) {
	cfg := loadConfig()
	exec.Command("jes-cli", "wallType", "2").Run()
	exec.Command("jes-cli", "wallShader", name).Run()

	// Для шейдера применяем matugen на основе текущего кэшированного изображения (если есть)
	var imagePath string
	if _, err := os.Stat(staticCache); err == nil {
		imagePath = staticCache
	} else if _, err := os.Stat(videoFrame); err == nil {
		imagePath = videoFrame
	}
	if imagePath != "" {
		applyMatugen(imagePath, double)
	} else {
		fmt.Fprintln(os.Stderr, "[wp] no cached wallpaper found for color scheme generation")
	}

	saveState("shader", cfg.State.Wallpaper, name, currentColorScheme)
}

// Переприменение текущих обоев с новой цветовой схемой (горячая перезагрузка)
func reapplyCurrentWithScheme() {
	cfg := loadConfig()
	if cfg.State.Mode == "image" && cfg.State.Wallpaper != "" {
		if _, err := os.Stat(staticCache); err == nil {
			exec.Command("matugen", "image", staticCache, "-m", "dark", "-t", currentColorScheme, "--source-color-index", "0").Run()
		}
	} else if cfg.State.Mode == "video" && cfg.State.Wallpaper != "" {
		if _, err := os.Stat(videoFrame); err == nil {
			exec.Command("matugen", "image", videoFrame, "-m", "dark", "-t", currentColorScheme, "--source-color-index", "0").Run()
		}
	}
	// Для шейдера — ничего не делаем (цветовая схема не используется)
}

func cmdSetScheme(scheme string) {
	var newScheme string
	switch scheme {
	case "vibrant":
		newScheme = "scheme-vibrant"
	case "classic":
		newScheme = "scheme-tonal-spot"
	default:
		fmt.Fprintln(os.Stderr, "set-scheme: expected 'vibrant' or 'classic'")
		os.Exit(1)
	}
	// Обновляем глобальную переменную
	currentColorScheme = newScheme
	// Сохраняем в конфиг
	cfg := loadConfig()
	saveState(cfg.State.Mode, cfg.State.Wallpaper, cfg.State.Shader, newScheme)
	// Горячая перезагрузка цветов
	reapplyCurrentWithScheme()
	fmt.Println("Color scheme set to", newScheme)
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
		fmt.Fprintln(os.Stderr, "usage: wallpaper-picker <list-tab <tab> [search]|get-state|cache-all|clean-cache|set <path> <bool>|set-shader <name> <bool>|set-scheme <vibrant/classic>>")
		os.Exit(1)
	}

	switch os.Args[1] {

	case "list-tab":
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

	case "fix-walls":
		cmdFixWalls()

	case "set":
		if len(os.Args) < 4 {
			fmt.Fprintln(os.Stderr, "set requires <path> and <bool>")
			os.Exit(1)
		}
		double, err := strconv.ParseBool(os.Args[3])
		if err != nil {
			fmt.Fprintln(os.Stderr, "invalid bool value:", os.Args[3])
			os.Exit(1)
		}
		cmdSet(os.Args[2], double)

	case "set-shader":
		if len(os.Args) < 4 {
			fmt.Fprintln(os.Stderr, "set-shader requires <name> and <bool>")
			os.Exit(1)
		}
		double, err := strconv.ParseBool(os.Args[3])
		if err != nil {
			fmt.Fprintln(os.Stderr, "invalid bool value:", os.Args[3])
			os.Exit(1)
		}
		cmdSetShader(os.Args[2], double)

	case "set-scheme":
		if len(os.Args) < 3 {
			fmt.Fprintln(os.Stderr, "set-scheme requires <vibrant/classic>")
			os.Exit(1)
		}
		cmdSetScheme(os.Args[2])

	default:
		fmt.Fprintln(os.Stderr, "unknown command:", os.Args[1])
		os.Exit(1)
	}
}
