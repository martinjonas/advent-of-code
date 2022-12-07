package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func part1(numbers []int) int {
	for _, first := range numbers {
		for _, second := range numbers {
			if first+second == 2020 {
				return (first * second)
			}
		}
	}

	return (-1)
}

func part2(numbers []int) int {
	for _, first := range numbers {
		for _, second := range numbers {
			for _, third := range numbers {
				if first+second+third == 2020 {
					return (first * second * third)
				}
			}
		}
	}

	return (-1)
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var numbers []int

	for scanner.Scan() {
		line := scanner.Text()
		number, _ := strconv.Atoi(line)
		numbers = append(numbers, number)
	}

	fmt.Printf("Part 1: %d\n", part1(numbers))
	fmt.Printf("Part 2: %d\n", part2(numbers))
}
