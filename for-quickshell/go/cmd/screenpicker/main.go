package main

import (
	"encoding/json"
	"fmt"
	"math"
	"os"
	"strconv"
)

type Output struct {
	Verts []float64 `json:"verts"`
	Tris  []int     `json:"tris"`
	BBox  []float64 `json:"bbox"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintln(os.Stderr, "usage: scrinpicker <width> <height> [side=250] [gap=6]")
		os.Exit(1)
	}
	w, _ := strconv.ParseFloat(os.Args[1], 64)
	h, _ := strconv.ParseFloat(os.Args[2], 64)

	side := 250.0
	gap := 6.0
	if len(os.Args) >= 4 {
		side, _ = strconv.ParseFloat(os.Args[3], 64)
	}
	if len(os.Args) >= 5 {
		gap, _ = strconv.ParseFloat(os.Args[4], 64)
	}

	height := side * math.Sqrt(3) / 2
	stepX := side/2 + gap
	stepY := height + gap

	// Сдвигаем сетку влево, чтобы треугольники выходили за левый край
	offsetX := -stepX * 1

	cols := int(math.Ceil((w - offsetX) / stepX)) + 2
	rows := int(math.Ceil(h/stepY)) + 2

	var verts []float64
	var tris []int
	var bbox []float64
	vertMap := make(map[[2]float64]int)

	addVert := func(x, y float64) int {
		key := [2]float64{math.Round(x*100) / 100, math.Round(y*100) / 100}
		if idx, ok := vertMap[key]; ok {
			return idx
		}
		idx := len(verts) / 2
		verts = append(verts, x, y)
		vertMap[key] = idx
		return idx
	}

	for row := 0; row < rows; row++ {
		for col := 0; col < cols; col++ {
			x0 := offsetX + float64(col)*stepX
			y0 := float64(row) * stepY

			// Ориентация чередуется: (row+col)%2 == 0 → вверх, иначе вниз
			up := (row+col)%2 == 0

			if up {
				// Треугольник вершиной вверх
				ax, ay := x0, y0+height
				bx, by := x0+side, y0+height
				cx, cy := x0+side/2, y0
				i1 := addVert(ax, ay)
				i2 := addVert(bx, by)
				i3 := addVert(cx, cy)
				tris = append(tris, i1, i2, i3)
				minX := math.Min(ax, math.Min(bx, cx))
				maxX := math.Max(ax, math.Max(bx, cx))
				minY := math.Min(ay, math.Min(by, cy))
				maxY := math.Max(ay, math.Max(by, cy))
				bbox = append(bbox, minX, maxX, minY, maxY)
			} else {
				// Треугольник вершиной вниз
				ax, ay := x0, y0
				bx, by := x0+side, y0
				cx, cy := x0+side/2, y0+height
				i1 := addVert(ax, ay)
				i2 := addVert(bx, by)
				i3 := addVert(cx, cy)
				tris = append(tris, i1, i2, i3)
				minX := math.Min(ax, math.Min(bx, cx))
				maxX := math.Max(ax, math.Max(bx, cx))
				minY := math.Min(ay, math.Min(by, cy))
				maxY := math.Max(ay, math.Max(by, cy))
				bbox = append(bbox, minX, maxX, minY, maxY)
			}
		}
	}

	out := Output{
		Verts: verts,
		Tris:  tris,
		BBox:  bbox,
	}
	json.NewEncoder(os.Stdout).Encode(out)
}
