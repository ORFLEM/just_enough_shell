package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

var (
	homeDir    = os.Getenv("HOME")
	defaultArt = filepath.Join(homeDir, ".config/quickshell/bar/images/music.png")
	cacheDir   = filepath.Join(homeDir, ".cache/qs_music_art")
	currentArt = filepath.Join(cacheDir, "current_art.jpg")

	lastOutput  string
	lastTrackKey string
	lastURL     string
	lastArtPath string
	lastArtVer  int64
	cooldown    time.Time

)

type Output struct {
	Artist string `json:"artist"`
	Title  string `json:"title"`
	Art    string `json:"art"`
	Status string `json:"status"`
	Ver    int64  `json:"ver"`
}

func playerctl(args ...string) (string, error) {
	out, err := exec.Command("playerctl", args...).Output()
	if err != nil {
		return "", err
	}
	return strings.TrimRight(string(out), "\n"), nil
}

func downloadArt(url string) (string, bool) {
	if url == lastURL {
		if _, err := os.Stat(currentArt); err == nil {
			return currentArt, false
		}
	}
	tmp := currentArt + ".tmp"
	os.Remove(tmp)
	cmd := exec.Command("curl", "-s", "-L", "-m", "5", url, "-o", tmp)
	if err := cmd.Run(); err != nil {
		os.Remove(tmp)
		return defaultArt, false
	}
	if fi, err := os.Stat(tmp); err != nil || fi.Size() == 0 {
		os.Remove(tmp)
		return defaultArt, false
	}
	os.Rename(tmp, currentArt)
	lastURL = url
	return currentArt, true
}

func processArt(art string) (string, bool) {
	if art == "" {
		return defaultArt, false
	}
	switch {
	case strings.HasPrefix(art, "http://") || strings.HasPrefix(art, "https://"):
		return downloadArt(art)

	case strings.HasPrefix(art, "data:"):
		fingerprint := art
		if len(fingerprint) > 128 {
			fingerprint = art[:128]
		}
		if fingerprint == lastURL {
			if _, err := os.Stat(currentArt); err == nil {
				return currentArt, false
			}
		}
		comma := strings.Index(art, ",")
		if comma == -1 {
			return defaultArt, false
		}
		raw := strings.NewReplacer(" ", "", "\n", "", "\r", "").Replace(art[comma+1:])
		decoded, err := base64.StdEncoding.DecodeString(raw)
		if err != nil {
			decoded, err = base64.RawStdEncoding.DecodeString(raw)
			if err != nil {
				return defaultArt, false
			}
		}
		tmp := currentArt + ".tmp"
		if err := os.WriteFile(tmp, decoded, 0644); err != nil {
			return defaultArt, false
		}
		os.Rename(tmp, currentArt)
		lastURL = fingerprint
		return currentArt, true

	case strings.HasPrefix(art, "file://"):
		path := art[7:]
		path = urlDecode(path)
		if _, err := os.Stat(path); err == nil {
			changed := path != lastURL
			if changed {
				lastURL = path
			}
			return path, changed
		}
		return defaultArt, false
	}
	return defaultArt, false
}

func urlDecode(s string) string {
	var b strings.Builder
	for i := 0; i < len(s); i++ {
		if s[i] == '%' && i+2 < len(s) {
			var c byte
			fmt.Sscanf(s[i+1:i+3], "%02x", &c)
			b.WriteByte(c)
			i += 2
		} else {
			b.WriteByte(s[i])
		}
	}
	return b.String()
}

func getAndOutput(force bool, statusOnly bool, artist, title, artURL string) {
    if !statusOnly && !force && time.Now().Before(cooldown) {
        return
    }
    status, _ := playerctl("status") // оставь, если хочешь быть уверен
    if status == "" {
        emit(Output{Art: defaultArt, Status: "󰐊", Ver: lastArtVer})
        return
    }

    // Ключ трека
    currentKey := artist + "\x00" + title
    trackChanged := currentKey != lastTrackKey
    if trackChanged {
        lastTrackKey = currentKey
        lastURL = ""
        os.Remove(currentArt)
    }

    icon := "󰐊"
    if status == "Playing" {
        icon = "󰏤"
    }

    var artPath string
    var artChanged bool

    if statusOnly && !trackChanged && artURL == lastURL {
        // реально ничего не изменилось
        artPath = lastArtPath
        if artPath == "" {
            artPath = defaultArt
        }
        artChanged = false
    } else {
        artPath, artChanged = processArt(artURL)
        if artChanged {
            lastArtPath = artPath
            lastArtVer = time.Now().UnixMilli()
        }
        cooldown = time.Now().Add(time.Second)

		// Если обложка пустая (mpris ещё не отдал artUrl) — эмитим что есть,
		// ждём 150мс и делаем вторую попытку
		if artURL == "" && trackChanged {
			out := Output{
				Artist: artist,
				Title:  title,
				Art:    artPath,
				Status: icon,
				Ver:    lastArtVer,
			}
			emit(out)
			time.Sleep(150 * time.Millisecond)
			artURL2, _ := playerctl("metadata", "--format", "{{mpris:artUrl}}")
			if artURL2 != "" {
				artPath, artChanged = processArt(artURL2)
				if artChanged {
					lastArtPath = artPath
					lastArtVer = time.Now().UnixMilli()
				}
			}
		}
	}

	out := Output{
		Artist: artist,
		Title:  title,
		Art:    artPath,
		Status: icon,
		Ver:    lastArtVer,
	}
	emit(out)
}

func emit(out Output) {
	b, _ := json.Marshal(out)
	s := string(b)
	if s != lastOutput {
		fmt.Println(s)
		lastOutput = s
	}
}

func main() {
	os.MkdirAll(cacheDir, 0755)

	getAndOutput(true, false, "", "", "")

	cmd := exec.Command("playerctl", "--follow", "metadata", "--format",
    "{{status}}\x1f{{artist}}\x1f{{title}}\x1f{{mpris:artUrl}}")

	cmd.Stderr = os.Stderr
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		os.Exit(1)
	}
	cmd.Start()

	buf := make([]byte, 4096)
	var carry string
	for {
		n, err := stdout.Read(buf)
		if n > 0 {
			carry += string(buf[:n])
			for {
				nl := strings.Index(carry, "\n")
				if nl == -1 {
					break
				}
				line := carry[:nl]
				carry = carry[nl+1:]

				parts := strings.SplitN(line, "\x1f", 4)
				newArtist := ""
				newStatus := ""
				newTitle := ""
				newArtURL := ""
				if len(parts) >= 1 {
					newStatus = parts[0]
				}
				if len(parts) >= 2 {
					newArtist = parts[1]
				}
				if len(parts) >= 3 {
					newTitle = parts[2]
				}
				if len(parts) >= 4 {
				    newArtURL = parts[3]
				}
				
				trackChanged := (newArtist + "\x00" + newTitle) != lastTrackKey
				artChanged  := newArtURL != lastURL
				force       := trackChanged || artChanged
				statusOnly  := !force && (newStatus == "Playing" || newStatus == "Paused")
				
				getAndOutput(force, statusOnly, newArtist, newTitle, newArtURL)
			}
		}
		if err != nil {
			break
		}
	}
}
