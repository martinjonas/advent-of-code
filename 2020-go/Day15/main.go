package main

import (
	"fmt"
)

func find_nth(numbers []int, nth int) int {
	saidLast := make(map[int]int)

	last := 0
	for i, n := range numbers {
		saidLast[n] = i
	}

	count := len(numbers)
	for count != nth - 1 {
		seenAt, seen := saidLast[last]
		saidLast[last] = count

		if seen {
			last = count - seenAt
		} else {
			last = 0
		}

		count++
	}

	return last
}

func main() {
	input := []int{1,20,11,6,12,0}
	fmt.Printf("Part 1: %d\n", find_nth(input, 2020))
	fmt.Printf("Part 2: %d\n", find_nth(input, 30000000))
}
