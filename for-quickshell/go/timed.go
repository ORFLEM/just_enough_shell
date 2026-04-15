package main

import (
	"fmt"
	"os"
	"strings"
	"time"
)

const stateFile = "/tmp/time_date_toggle"

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: timed {t-d|show}")
		os.Exit(1)
	}

	// Инициализация состояния
	if _, err := os.Stat(stateFile); os.IsNotExist(err) {
		_ = os.WriteFile(stateFile, []byte("time"), 0644)
	}

	switch os.Args[1] {
	case "t-d":
		toggleState()
	case "show":
		showLoop()
	default:
		fmt.Fprintln(os.Stderr, "Unknown command")
		os.Exit(1)
	}
}

func toggleState() {
	state, _ := os.ReadFile(stateFile)
	current := strings.TrimSpace(string(state))

	if current == "time" {
		_ = os.WriteFile(stateFile, []byte("date"), 0644)
	} else {
		_ = os.WriteFile(stateFile, []byte("time"), 0644)
	}
}

func showLoop() {
	ticker := time.NewTicker(50 * time.Millisecond)
	defer ticker.Stop()

	var lastOutput string

	for range ticker.C {
		state, _ := os.ReadFile(stateFile)
		current := strings.TrimSpace(string(state))

		var output string
		now := time.Now()

		if current == "time" {
			output = now.Format("15:04:05")
		} else {
			output = now.Format("02-01-2006")
		}

		// Выводим только при изменении
		if output != lastOutput {
			fmt.Println(output)
			lastOutput = output
		}
	}
}
