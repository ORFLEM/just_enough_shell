package main

import (
	"bufio"
	"encoding/json"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type App struct {
	Name     string `json:"name"`
	Exec     string `json:"exec"`
	Icon     string `json:"icon"`
	Comment  string `json:"comment"`
	Terminal bool   `json:"terminal"`
	File     string `json:"file"`
}

type FreqDB map[string]int

func freqPath() string {
	return filepath.Join(os.Getenv("HOME"), ".local/share/quickshell/launch-freq.json")
}

func loadFreq() FreqDB {
	db := FreqDB{}
	data, err := os.ReadFile(freqPath())
	if err != nil {
		return db
	}
	json.Unmarshal(data, &db)
	return db
}

func saveFreq(db FreqDB) {
	dir := filepath.Dir(freqPath())
	os.MkdirAll(dir, 0755)
	data, _ := json.Marshal(db)
	os.WriteFile(freqPath(), data, 0644)
}

func parseDesktop(path string) (App, bool) {
	f, err := os.Open(path)
	if err != nil {
		return App{}, false
	}
	defer f.Close()

	var app App
	app.File = path
	inEntry := false

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()

		if line == "[Desktop Entry]" {
			inEntry = true
			continue
		}
		if strings.HasPrefix(line, "[") {
			inEntry = false
			continue
		}
		if !inEntry {
			continue
		}

		k, v, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}

		switch k {
		case "Name":     app.Name = v
		case "Exec":     app.Exec = cleanExec(v)
		case "Icon":     app.Icon = v
		case "Comment":  app.Comment = v
		case "Terminal": app.Terminal = v == "true"
		case "NoDisplay":
			if v == "true" {
				return App{}, false
			}
		case "Hidden":
			if v == "true" {
				return App{}, false
			}
		case "Type":
			if v != "Application" {
				return App{}, false
			}
		}
	}

	if app.Name == "" || app.Exec == "" {
		return App{}, false
	}
	return app, true
}

func cleanExec(exec string) string {
	var result []string
	for _, part := range strings.Fields(exec) {
		if len(part) == 2 && part[0] == '%' {
			continue
		}
		result = append(result, part)
	}
	return strings.Join(result, " ")
}

func getDesktopDirs() []string {
	home := os.Getenv("HOME")
	return []string{
		filepath.Join(home, ".local/share/applications"),
		"/run/current-system/sw/share/applications",
		"/var/lib/flatpak/exports/share/applications",
	}
}

func listApps(search string) []App {
	seen := map[string]bool{}
	apps := []App{}
	search = strings.ToLower(search)

	for _, dir := range getDesktopDirs() {
		entries, err := os.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, e := range entries {
			if !strings.HasSuffix(e.Name(), ".desktop") {
				continue
			}
			// дедупликация по имени файла, не по полному пути
			if seen[e.Name()] {
				continue
			}
			seen[e.Name()] = true

			app, ok := parseDesktop(filepath.Join(dir, e.Name()))
			if !ok {
				continue
			}

			if search != "" {
				if !strings.Contains(strings.ToLower(app.Name), search) &&
					!strings.Contains(strings.ToLower(app.Comment), search) {
					continue
				}
			}
			apps = append(apps, app)
		}
	}
	return apps
}

func main() {
	// launch --launched <name>  — записать запуск
	if len(os.Args) > 1 && os.Args[1] == "--launched" {
		if len(os.Args) > 2 {
			db := loadFreq()
			db[os.Args[2]]++
			saveFreq(db)
		}
		return
	}

	search := ""
	if len(os.Args) > 1 {
		search = os.Args[1]
	}

	freq := loadFreq()
	apps := listApps(search)

	sort.Slice(apps, func(i, j int) bool {
		fi, fj := freq[apps[i].Name], freq[apps[j].Name]
		if fi != fj {
			return fi > fj
		}
		return strings.ToLower(apps[i].Name) < strings.ToLower(apps[j].Name)
	})

	json.NewEncoder(os.Stdout).Encode(apps)
}
