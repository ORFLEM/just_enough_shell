package main

import (
	"bufio"
	"encoding/json"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Унифицированный формат вывода для QML
type UnifiedApp struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Icon     string `json:"icon"`
	Exec     string `json:"exec"`
	Comment  string `json:"comment"`
	Keywords string `json:"keywords"`
}

// Внутреннее представление .desktop
type desktopApp struct {
	Name     string
	Exec     string
	Icon     string
	Terminal bool
	Comment  string
	Keywords string
	File     string
}

type FreqDB map[string]int

func freqPath() string {
	return filepath.Join(os.Getenv("HOME"), ".local/state/JES-launch-freq.json")
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

	tmpFile := freqPath() + ".tmp"
	if err := os.WriteFile(tmpFile, data, 0644); err == nil {
		os.Rename(tmpFile, freqPath())
	}
}

// Чистка кеша от софта, которого больше нет в системе
func cleanFreq(db FreqDB, apps []desktopApp) FreqDB {
	validApps := make(map[string]bool, len(apps))
	for _, app := range apps {
		validApps[app.Name] = true
	}

	cleaned := FreqDB{}
	for name, count := range db {
		if validApps[name] {
			cleaned[name] = count
		}
	}
	return cleaned
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
		case "Keywords":
			app.Keywords = strings.ReplaceAll(v, ";", " ")
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

func quoteArg(s string) string {
	return "'" + strings.ReplaceAll(s, "'", "'\\''") + "'"
}

func getDesktopDirs() []string {
	home := os.Getenv("HOME")
	return []string{
		filepath.Join(home, ".local/share/applications"),
		"/run/current-system/sw/share/applications",
		"/var/lib/flatpak/exports/share/applications",
		"/usr/share/applications/",
	}
}

func listApps() []desktopApp {
	seen := map[string]bool{}
	apps := []desktopApp{}

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

	freq := loadFreq()
	apps := listApps()

	// Очищаем кеш от удаленного софта и сохраняем обновленный JSON
	freq = cleanFreq(freq, apps)
	saveFreq(freq)

	// Сортировка по частоте использования
	sort.Slice(apps, func(i, j int) bool {
		fi, fj := freq[apps[i].Name], freq[apps[j].Name]
		if fi != fj {
			return fi > fj
		}
		return strings.ToLower(apps[i].Name) < strings.ToLower(apps[j].Name)
	})

	// Путь к собственному бинарнику
	selfExec, err := os.Executable()
	if err != nil {
		selfExec = os.Args[0]
	}

	// Преобразование в унифицированный формат
	unified := make([]UnifiedApp, 0, len(apps))
	for _, app := range apps {
		exec := app.Exec
		if app.Terminal {
			term := os.Getenv("TERMINAL")
			if term == "" {
				term = "xterm"
			}
			escaped := strings.ReplaceAll(exec, "'", "'\\''")
			exec = term + " -e sh -c '" + escaped + "'"
		}

		launchCmd := selfExec + " --launched " + quoteArg(app.Name) + " && " + exec

		unified = append(unified, UnifiedApp{
			ID:       app.File,
			Name:     app.Name,
			Icon:     app.Icon,
			Exec:     launchCmd,
			Comment:  app.Comment,
			Keywords: app.Keywords,
		})
	}
	json.NewEncoder(os.Stdout).Encode(unified)
}
