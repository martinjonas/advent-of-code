package main

import (
	"bufio"
	"fmt"
	"os"
)

func countValues(m map[rune]int, target int) int {
	result := 0

	for _, v := range m {
		if v == target {
			result++
		}
	}

	return result
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	groups := make(map[rune]int)
	groupSize := 0
	part1 := 0
	part2 := 0

	for scanner.Scan() {
		line := scanner.Text()

		if line == "" {
			part1 += len(groups)
			part2 += countValues(groups, groupSize)

			groups = make(map[rune]int)
			groupSize = 0
			continue
		}

		groupSize += 1
		for _, r := range line {
			groups[r] += 1
		}
	}

	part1 += len(groups)
	part2 += countValues(groups, groupSize)

	fmt.Printf("Part 1: %d\n", part1)
	fmt.Printf("Part 2: %d\n", part2)
}
