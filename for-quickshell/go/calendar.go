package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/fsnotify/fsnotify"
)

const (
	stateFile    = ".config/eww/calendar_state"
	holidaysFile = ".config/eww/holidays.txt"
)

var monthNames = []string{
	"", "январь", "февраль", "март", "апрель", "май", "июнь",
	"июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь",
}

type State struct {
	Year  int    `json:"year"`
	Month int    `json:"month"`
	Mode  string `json:"mode"`
}

type Day struct {
	Day     int    `json:"day"`
	Style   string `json:"style"`
	Holiday string `json:"holiday,omitempty"`
}

type MonthCalendar struct {
	Mode      string         `json:"mode"`
	Year      int            `json:"year"`
	MonthName string         `json:"month_name"`
	Days      map[string]Day `json:",inline"`
}

type MonthInfo struct {
	Month   int    `json:"month"`
	Name    string `json:"name"`
	Current bool   `json:"cur"`
}

type YearCalendar struct {
	Mode   string               `json:"mode"`
	Year   int                  `json:"year"`
	Months map[string]MonthInfo `json:",inline"`
}

type Holiday struct {
	Day   int
	Month int
	Year  int // 0 = ежегодный
	Name  string
}

var holidays []Holiday

func main() {
	if len(os.Args) < 2 {
		generateOutput()
		return
	}

	homeDir, _ := os.UserHomeDir()
	stateFilePath := filepath.Join(homeDir, stateFile)
	holidaysFilePath := filepath.Join(homeDir, holidaysFile)

	loadHolidays(holidaysFilePath)

	switch os.Args[1] {
	case "listen":
		listenMode(stateFilePath)
	case "next":
		navigate(stateFilePath, 1, false)
	case "prev":
		navigate(stateFilePath, -1, false)
	case "next_year":
		navigate(stateFilePath, 1, true)
	case "prev_year":
		navigate(stateFilePath, -1, true)
	case "today":
		resetToToday(stateFilePath)
	case "toggle_mode":
		toggleMode(stateFilePath)
	case "select_month":
		if len(os.Args) < 3 {
			fmt.Fprintln(os.Stderr, "Укажите номер месяца (1-12)")
			os.Exit(1)
		}
		month, _ := strconv.Atoi(os.Args[2])
		selectMonth(stateFilePath, month)
	case "reset":
		resetToToday(stateFilePath)
	default:
		fmt.Fprintln(os.Stderr, "Unknown command")
		os.Exit(1)
	}
}

func loadHolidays(path string) {
	file, err := os.Open(path)
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.SplitN(line, "-", 2)
		if len(parts) != 2 {
			continue
		}

		dateParts := strings.Split(parts[0], "|")
		if len(dateParts) != 3 {
			continue
		}

		day, _ := strconv.Atoi(dateParts[0])
		month, _ := strconv.Atoi(dateParts[1])
		year := 0
		if dateParts[2] != "*" {
			year, _ = strconv.Atoi(dateParts[2])
		}

		holidays = append(holidays, Holiday{
			Day:   day,
			Month: month,
			Year:  year,
			Name:  parts[1],
		})
	}
}

func getHoliday(day, month, year int) string {
	// Точное совпадение
	for _, h := range holidays {
		if h.Day == day && h.Month == month && h.Year == year {
			return h.Name
		}
	}
	// Ежегодный праздник
	for _, h := range holidays {
		if h.Day == day && h.Month == month && h.Year == 0 {
			return h.Name
		}
	}
	return ""
}

func loadState(path string) State {
	data, err := os.ReadFile(path)
	if err != nil {
		now := time.Now()
		return State{Year: now.Year(), Month: int(now.Month()), Mode: "month"}
	}

	var state State
	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		switch parts[0] {
		case "year":
			state.Year, _ = strconv.Atoi(parts[1])
		case "month":
			state.Month, _ = strconv.Atoi(parts[1])
		case "mode":
			state.Mode = parts[1]
		}
	}
	return state
}

func saveState(path string, state State) {
	content := fmt.Sprintf("year=%d\nmonth=%d\nmode=%s\n", state.Year, state.Month, state.Mode)
	os.MkdirAll(filepath.Dir(path), 0755)
	os.WriteFile(path, []byte(content), 0644)
}

func generateMonthCalendar(state State) MonthCalendar {
	now := time.Now()
	currentYear, currentMonth, currentDay := now.Year(), int(now.Month()), now.Day()

	firstDay := time.Date(state.Year, time.Month(state.Month), 1, 0, 0, 0, 0, time.Local)
	daysInMonth := time.Date(state.Year, time.Month(state.Month+1), 0, 0, 0, 0, 0, time.Local).Day()

	// День недели первого числа (понедельник=0)
	weekday := int(firstDay.Weekday())
	if weekday == 0 {
		weekday = 7
	}
	weekday-- // Преобразуем к 0=понедельник

	cal := MonthCalendar{
		Mode:      "month",
		Year:      state.Year,
		MonthName: monthNames[state.Month],
		Days:      make(map[string]Day),
	}

	// Предыдущий месяц
	prevMonth := state.Month - 1
	prevYear := state.Year
	if prevMonth == 0 {
		prevMonth = 12
		prevYear--
	}
	daysInPrevMonth := time.Date(prevYear, time.Month(prevMonth+1), 0, 0, 0, 0, 0, time.Local).Day()

	// Следующий месяц
	nextMonth := state.Month + 1
	nextYear := state.Year
	if nextMonth == 13 {
		nextMonth = 1
		nextYear++
	}

	dayIndex := 0

	// Дни предыдущего месяца
	for i := daysInPrevMonth - weekday + 1; i <= daysInPrevMonth; i++ {
		style := "omonth"
		holiday := getHoliday(i, prevMonth, prevYear)

		if prevYear == currentYear && prevMonth == currentMonth && i == currentDay {
			style = "today"
		} else if holiday != "" {
			style = "oholiday"
		} else if dayIndex%7 == 5 || dayIndex%7 == 6 {
			style = "oweekend"
		}

		cal.Days[fmt.Sprintf("day%d", dayIndex)] = Day{
			Day:     i,
			Style:   style,
			Holiday: holiday,
		}
		dayIndex++
	}

	// Дни текущего месяца
	for i := 1; i <= daysInMonth; i++ {
		style := "tmonth"
		holiday := getHoliday(i, state.Month, state.Year)

		if state.Year == currentYear && state.Month == currentMonth && i == currentDay {
			style = "today"
		} else if holiday != "" {
			style = "tholiday"
		} else if dayIndex%7 == 5 || dayIndex%7 == 6 {
			style = "tweekend"
		}

		cal.Days[fmt.Sprintf("day%d", dayIndex)] = Day{
			Day:     i,
			Style:   style,
			Holiday: holiday,
		}
		dayIndex++
	}

	// Дни следующего месяца
	for i := 1; dayIndex < 42; i++ {
		style := "omonth"
		holiday := getHoliday(i, nextMonth, nextYear)

		if nextYear == currentYear && nextMonth == currentMonth && i == currentDay {
			style = "today"
		} else if holiday != "" {
			style = "oholiday"
		} else if dayIndex%7 == 5 || dayIndex%7 == 6 {
			style = "oweekend"
		}

		cal.Days[fmt.Sprintf("day%d", dayIndex)] = Day{
			Day:     i,
			Style:   style,
			Holiday: holiday,
		}
		dayIndex++
	}

	return cal
}

func generateYearCalendar(state State) YearCalendar {
	now := time.Now()
	currentYear, currentMonth := now.Year(), int(now.Month())

	cal := YearCalendar{
		Mode:   "year",
		Year:   state.Year,
		Months: make(map[string]MonthInfo),
	}

	for i := 1; i <= 12; i++ {
		cal.Months[fmt.Sprintf("month%d", i)] = MonthInfo{
			Month:   i,
			Name:    monthNames[i],
			Current: state.Year == currentYear && i == currentMonth,
		}
	}

	return cal
}

func generateOutput() {
	homeDir, _ := os.UserHomeDir()
	stateFilePath := filepath.Join(homeDir, stateFile)
	holidaysFilePath := filepath.Join(homeDir, holidaysFile)

	loadHolidays(holidaysFilePath)
	state := loadState(stateFilePath)

	var output []byte
	if state.Mode == "year" {
		output, _ = json.Marshal(generateYearCalendar(state))
	} else {
		output, _ = json.Marshal(generateMonthCalendar(state))
	}

	fmt.Println(string(output))
}

func listenMode(stateFilePath string) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to create watcher:", err)
		os.Exit(1)
	}
	defer watcher.Close()

	// Убеждаемся, что файл существует
	if _, err := os.Stat(stateFilePath); os.IsNotExist(err) {
		resetToToday(stateFilePath)
	}

	watcher.Add(stateFilePath)

	// Первичный вывод
	generateOutput()

	// Следим за изменениями
	ticker := time.NewTicker(50 * time.Millisecond)
	defer ticker.Stop()

	lastOutput := ""

	for {
		select {
		case event := <-watcher.Events:
			if event.Op&fsnotify.Write == fsnotify.Write {
				time.Sleep(10 * time.Millisecond) // Дебаунс
				state := loadState(stateFilePath)

				var output []byte
				if state.Mode == "year" {
					output, _ = json.Marshal(generateYearCalendar(state))
				} else {
					output, _ = json.Marshal(generateMonthCalendar(state))
				}

				outputStr := string(output)
				if outputStr != lastOutput {
					fmt.Println(outputStr)
					lastOutput = outputStr
				}
			}
		case <-ticker.C:
			// Проверка раз в 50ms на случай пропущенных событий
		}
	}
}

func navigate(path string, delta int, yearOnly bool) {
	state := loadState(path)

	if yearOnly {
		state.Year += delta
	} else if state.Mode == "month" {
		state.Month += delta
		if state.Month > 12 {
			state.Month = 1
			state.Year++
		} else if state.Month < 1 {
			state.Month = 12
			state.Year--
		}
	} else {
		state.Year += delta
	}

	saveState(path, state)
}

func resetToToday(path string) {
	now := time.Now()
	saveState(path, State{
		Year:  now.Year(),
		Month: int(now.Month()),
		Mode:  "month",
	})
}

func toggleMode(path string) {
	state := loadState(path)
	if state.Mode == "month" {
		state.Mode = "year"
	} else {
		state.Mode = "month"
	}
	saveState(path, state)
}

func selectMonth(path string, month int) {
	if month < 1 || month > 12 {
		return
	}
	state := loadState(path)
	state.Month = month
	state.Mode = "month"
	saveState(path, state)
}

