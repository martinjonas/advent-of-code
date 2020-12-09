package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func isSum(number int, numbers []int) bool {
	for i, x := range numbers {
		for _, y := range numbers[i+1:] {
			if number == x + y {
				return true
			}
		}
	}

	return false
}

func part1(numbers []int) int {
	windowSize := 25

	availableNumbers := numbers[:windowSize]

	for i, number := range numbers[windowSize:] {
		if !isSum(number, availableNumbers) {
			return number
		}

		availableNumbers = numbers[i+1: i+windowSize+1]
	}

	return -1
}

func part2(numbers []int, sumTo int) int {
	// naive algorithm, but the input was quite small…
	for i := 0; i < len(numbers); i++ {
		for j := i+1; j < len(numbers); j++ {
			sum := 0
			min := numbers[i]
			max := numbers[i]

			for _, x := range numbers[i:j] {
				if x < min {
					min = x
				}

				if x > max {
					max = x
				}

				sum += x
			}

			if sumTo == sum {
				return min + max
			}

			if sum > sumTo {
				break
			}
		}
	}

	return -1
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

	p1 := part1(lines)
	fmt.Printf("Part 1: %d\n", p1)
	fmt.Printf("Part 2: %d\n", part2(lines, p1))
}
