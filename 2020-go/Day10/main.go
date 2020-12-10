package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
)

func part1(adapters []int) int {
	current := 0
	differences := [4]int{0,0,0,1}

	for _, adapter := range adapters {
		differences[adapter-current]++
		current = adapter
	}

	return differences[1] * differences[3]
}

func part2(adapters []int) int {
	arrangements := make(map[int]int)
	arrangements[0] = 1

	for _, adapter := range adapters {
		arrangements[adapter] =
			arrangements[adapter-1] +
			arrangements[adapter-2] +
			arrangements[adapter-3]
	}

	return arrangements[adapters[len(adapters)-1]]
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var lines []int

	for scanner.Scan() {
		line := scanner.Text()

		i, _ := strconv.Atoi(line)
		lines = append(lines, i)
	}

	sort.Ints(lines)
	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
