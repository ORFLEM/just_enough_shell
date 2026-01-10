package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
)

const (
	pipePath   = "/tmp/cava_eww.fifo"
	configPath = "/tmp/cava_eww_config"
	configContent = `[general]
bars = 20
framerate = 60
sleep_timer = 1
[input]
method = pulse
[output]
method = raw
raw_target = /tmp/cava_eww.fifo
data_format = ascii
ascii_max_range = 7
`
)

var blocks = []rune{'▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}

func main() {
	// Убиваем старые процессы cava
	exec.Command("pkill", "-x", "cava").Run()

	// Создаём named pipe
	syscall.Unlink(pipePath)
	if err := syscall.Mkfifo(pipePath, 0644); err != nil {
		fmt.Fprintln(os.Stderr, "Failed to create FIFO:", err)
		os.Exit(1)
	}

	// Создаём конфиг cava
	if err := os.WriteFile(configPath, []byte(configContent), 0644); err != nil {
		fmt.Fprintln(os.Stderr, "Failed to create config:", err)
		os.Exit(1)
	}

	// Запускаем cava
	cmd := exec.Command("cava", "-p", configPath)
	if err := cmd.Start(); err != nil {
		fmt.Fprintln(os.Stderr, "Failed to start cava:", err)
		os.Exit(1)
	}

	// Обработка сигналов для корректного завершения
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigChan
		cmd.Process.Kill()
		syscall.Unlink(pipePath)
		os.Remove(configPath)
		os.Exit(0)
	}()

	// Открываем FIFO для чтения
	pipe, err := os.Open(pipePath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to open FIFO:", err)
		os.Exit(1)
	}
	defer pipe.Close()

	scanner := bufio.NewScanner(pipe)
	lastOutput := ""

	// Создаём буфер для быстрой замены
	var builder strings.Builder
	builder.Grow(20) // Предаллокация для 20 баров

	for scanner.Scan() {
		line := scanner.Text()
		builder.Reset()

		// Быстрая замена без регулярок
		for _, char := range line {
			if char >= '0' && char <= '7' {
				builder.WriteRune(blocks[char-'0'])
			}
			// Пропускаем ';' и другие символы
		}

		result := builder.String()

		// Выводим только при изменении
		if result != lastOutput {
			fmt.Println(result)
			lastOutput = result
		}
	}

	// Завершение
	cmd.Process.Kill()
	syscall.Unlink(pipePath)
	os.Remove(configPath)
}
