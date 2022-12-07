package main

import (
	"bufio"
	"fmt"
	"os"
)

func get_pos(rows []string, col, row int) byte {
	r := rows[row]
	return r[col % len(r)]
}

func part1(rows []string, slope_col, slope_row int) int {
	col, row := 0, 0

	trees := 0
	for row < len(rows) {
		if get_pos(rows, col, row) == '#' {
			trees++
		}
		col += slope_col
		row += slope_row
	}

	return trees
}

func part2(rows []string) int {
	return part1(rows, 1, 1) *
		part1(rows, 3, 1) *
		part1(rows, 5, 1) *
		part1(rows, 7, 1) *
		part1(rows, 1, 2)
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var rows []string

	for scanner.Scan() {
		line := scanner.Text()
		rows = append(rows, line)
	}

	fmt.Printf("Part 1: %d\n", part1(rows, 3, 1))
	fmt.Printf("Part 2: %d\n", part2(rows))
}
