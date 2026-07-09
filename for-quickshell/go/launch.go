package main

import (
	"bufio"
	"encoding/json"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Унифицированный формат вывода
type UnifiedApp struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Icon string `json:"icon"`
	Exec string `json:"exec"`
}

// Внутреннее представление .desktop
type desktopApp struct {
	Name     string
	Exec     string
	Icon     string
	Terminal bool
	Comment  string // добавлено
	File     string
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

func parseDesktop(path string) (desktopApp, bool) {
	f, err := os.Open(path)
	if err != nil {
		return desktopApp{}, false
	}
	defer f.Close()

	var app desktopApp
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
		case "Name":
			app.Name = v
		case "Exec":
			app.Exec = cleanExec(v)
		case "Icon":
			app.Icon = v
		case "Comment":
			app.Comment = v
		case "Terminal":
			app.Terminal = v == "true"
		case "NoDisplay":
			if v == "true" {
				return desktopApp{}, false
			}
		case "Hidden":
			if v == "true" {
				return desktopApp{}, false
			}
		case "Type":
			if v != "Application" {
				return desktopApp{}, false
			}
		}
	}

	if app.Name == "" || app.Exec == "" {
		return desktopApp{}, false
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

func listApps(search string) []desktopApp {
	seen := map[string]bool{}
	apps := []desktopApp{}
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
					!strings.Contains(strings.ToLower(app.Exec), search) &&
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
	// Запись факта запуска
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

	// Сортировка по частоте использования
	sort.Slice(apps, func(i, j int) bool {
		fi, fj := freq[apps[i].Name], freq[apps[j].Name]
		if fi != fj {
			return fi > fj
		}
		return strings.ToLower(apps[i].Name) < strings.ToLower(apps[j].Name)
	})

	// Преобразование в унифицированный формат
	unified := make([]UnifiedApp, 0, len(apps))
	for _, app := range apps {
		exec := app.Exec
		if app.Terminal {
			term := os.Getenv("TERMINAL")
			if term == "" {
				term = "xterm"
			}
			// Экранирование одинарных кавычек для безопасной передачи в sh -c
			escaped := strings.ReplaceAll(exec, "'", "'\\''")
			exec = term + " -e sh -c '" + escaped + "'"
		}
		unified = append(unified, UnifiedApp{
			ID:   app.File, // уникальный идентификатор – путь к .desktop
			Name: app.Name,
			Icon: app.Icon,
			Exec: exec,
		})
	}

	json.NewEncoder(os.Stdout).Encode(unified)
}
