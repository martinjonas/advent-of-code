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
	oneDifferences := 0
	threeDifferences := 1

	for _, adapter := range adapters {
		if adapter == current+1 {
			oneDifferences += 1
		}

		if adapter == current+3 {
			threeDifferences += 1
		}

		current = adapter
	}

	return oneDifferences * threeDifferences
}

type IntPair struct {
	fst, snd int
}

func countArrangements(adapters []int, current int, cache map[IntPair]int) int {
	if len(adapters) == 0 {
		return 0
	}

	first := adapters[0]

	if first-current > 3 {
		return 0
	}

	if len(adapters) == 1 {
		return 1
	}

	key := IntPair{first, current}
	res, seen := cache[key]
	if seen {
		return res
	}

	withFirst := countArrangements(adapters[1:], first, cache)
	withoutFirst := countArrangements(adapters[1:], current, cache)
	result := withFirst + withoutFirst

	cache[key] = result
	return result
}

func part2(adapters []int) int {
	cache := make(map[IntPair]int)
	return countArrangements(adapters, 0, cache)
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
