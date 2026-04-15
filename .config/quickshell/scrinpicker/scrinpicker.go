package main

import (
	"encoding/json"
	"fmt"
	"math"
	"os"
	"strconv"
)

type Point struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type Triangle struct {
	A Point `json:"a"`
	B Point `json:"b"`
	C Point `json:"c"`
}

func generateEquilateral(w, h float64, spacing float64) []Triangle {
	// Вычисляем размер треугольника (высота = spacing * 0.866, если равносторонний)
	// Но проще задать ширину треугольника = spacing, тогда высота = spacing * sqrt(3)/2
	// Делаем треугольники с зазором 3px между ними (gap = spacing)
	
	side := spacing          // сторона треугольника
	height := side * math.Sqrt(3) / 2  // высота равностороннего треугольника
	
	// Количество треугольников по горизонтали и вертикали с учётом зазора
	// Учитываем, что треугольники могут быть "вверх" и "вниз" в шахматном порядке
	cols := int(math.Floor(w / side)) + 1
	rows := int(math.Floor(h / height)) + 1
	
	var tris []Triangle
	
	for row := 0; row < rows; row++ {
		for col := 0; col < cols; col++ {
			// Базовые координаты (верхний левый угол bounding box)
			x0 := float64(col) * side
			y0 := float64(row) * height
			
			// Для чётных и нечётных рядов — разное смещение (шахматный порядок)
			if row%2 == 0 {
				// Треугольник вершиной вверх
				a := Point{x0, y0}
				b := Point{x0 + side, y0}
				c := Point{x0 + side/2, y0 + height}
				tris = append(tris, Triangle{a, b, c})
				
				// Соседний треугольник вершиной вниз (если есть место)
				if row < rows-1 {
					a2 := Point{x0, y0 + height}
					b2 := Point{x0 + side, y0 + height}
					c2 := Point{x0 + side/2, y0}
					tris = append(tris, Triangle{a2, b2, c2})
				}
			} else {
				// Сдвиг для нечётного ряда на полшага вправо
				x0Shift := x0 + side/2
				if x0Shift+side <= w {
					a := Point{x0Shift, y0}
					b := Point{x0Shift + side, y0}
					c := Point{x0Shift + side/2, y0 + height}
					tris = append(tris, Triangle{a, b, c})
					
					if row < rows-1 {
						a2 := Point{x0Shift, y0 + height}
						b2 := Point{x0Shift + side, y0 + height}
						c2 := Point{x0Shift + side/2, y0}
						tris = append(tris, Triangle{a2, b2, c2})
					}
				}
			}
		}
	}
	
	// Обрезаем треугольники, выходящие за границы экрана
	// И сжимаем их к центру на gap (3px)
	gap := spacing // зазор = 3px
	var result []Triangle
	for _, t := range tris {
		// Вычисляем центр треугольника
		cx := (t.A.X + t.B.X + t.C.X) / 3
		cy := (t.A.Y + t.B.Y + t.C.Y) / 3
		
		// Сжимаем треугольник к центру, оставляя зазор между соседними
		shrink := func(p Point) Point {
			// Не трогаем точки на краях экрана
			if p.X <= 0.5 || p.X >= w-0.5 || p.Y <= 0.5 || p.Y >= h-0.5 {
				return p
			}
			dx := p.X - cx
			dy := p.Y - cy
			l := math.Hypot(dx, dy)
			if l < 0.001 {
				return p
			}
			s := math.Min(gap, l*0.45)
			return Point{p.X - dx/l*s, p.Y - dy/l*s}
		}
		
		na := shrink(t.A)
		nb := shrink(t.B)
		nc := shrink(t.C)
		
		// Проверяем, что треугольник всё ещё внутри экрана (можно оставить как есть)
		result = append(result, Triangle{na, nb, nc})
	}
	
	return result
}

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintln(os.Stderr, "usage: scrinpicker <width> <height>")
		os.Exit(1)
	}
	w, _ := strconv.ParseFloat(os.Args[1], 64)
	h, _ := strconv.ParseFloat(os.Args[2], 64)
	
	// Генерируем равносторонние треугольники с зазором 3px
	tris := generateEquilateral(w, h, 3.0)
	
	// Выводим JSON
	out, _ := json.Marshal(tris)
	fmt.Println(string(out))
}
