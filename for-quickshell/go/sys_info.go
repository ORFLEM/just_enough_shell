package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

type Stats struct {
	CPU int `json:"cpu"`
	MEM int `json:"mem"`
	GPU int `json:"gpu"`
}

var (
	prevTotal uint64
	prevIdle  uint64
)

func main() {
	ticker := time.NewTicker(300 * time.Millisecond)
	defer ticker.Stop()

	var lastOutput string

	for range ticker.C {
		stats := Stats{
			CPU: getCPU(),
			MEM: getMEM(),
			GPU: getGPU(),
		}

		output, _ := json.Marshal(stats)
		outputStr := string(output)

		if outputStr != lastOutput {
			fmt.Println(outputStr)
			lastOutput = outputStr
		}
	}
}

// getCPU возвращает загрузку CPU в процентах
func getCPU() int {
	file, err := os.Open("/proc/stat")
	if err != nil {
		return 0
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	if !scanner.Scan() {
		return 0
	}

	line := scanner.Text()
	fields := strings.Fields(line)
	if len(fields) < 5 || fields[0] != "cpu" {
		return 0
	}

	// Парсим значения CPU
	var total, idle uint64
	for i := 1; i < len(fields); i++ {
		val, _ := strconv.ParseUint(fields[i], 10, 64)
		total += val
		if i == 4 { // idle
			idle = val
		}
		if i == 5 { // iowait
			idle += val
		}
	}

	// Вычисляем процент использования
	if prevTotal == 0 {
		prevTotal = total
		prevIdle = idle
		return 0
	}

	diffTotal := total - prevTotal
	diffIdle := idle - prevIdle

	prevTotal = total
	prevIdle = idle

	if diffTotal == 0 {
		return 0
	}

	usage := (1000 * (diffTotal - diffIdle) / diffTotal) / 10
	return int(usage)
}

// getMEM возвращает использование памяти в процентах
func getMEM() int {
	file, err := os.Open("/proc/meminfo")
	if err != nil {
		return 0
	}
	defer file.Close()

	var memTotal, memAvailable uint64
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)
		if len(fields) < 2 {
			continue
		}

		val, _ := strconv.ParseUint(fields[1], 10, 64)

		switch fields[0] {
		case "MemTotal:":
			memTotal = val
		case "MemAvailable:":
			memAvailable = val
		}

		if memTotal > 0 && memAvailable > 0 {
			break
		}
	}

	if memTotal == 0 {
		return 0
	}

	memUsed := memTotal - memAvailable
	return int((memUsed * 100) / memTotal)
}

// getGPU возвращает загрузку AMD GPU в процентах
func getGPU() int {
	data, err := os.ReadFile("/sys/class/drm/card1/device/gpu_busy_percent")
	if err != nil {
		return 0
	}

	val, _ := strconv.Atoi(strings.TrimSpace(string(data)))
	return val
}
