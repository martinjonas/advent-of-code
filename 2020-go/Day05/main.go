package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sort"
)

func part2(seats []int) int {
	sort.Ints(seats)

	for i, v := range seats {
		if i < len(seats) - 1 && seats[i+1] == v+2  {
			return v+1
		}
	}

	return -1
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var max int
	var seats []int

	for scanner.Scan() {
		line := scanner.Text()

		replacer := strings.NewReplacer("F", "0", "B", "1", "L", "0", "R", "1")
		line = replacer.Replace(line)

		id64, _ := strconv.ParseInt(line, 2, 0)
		id := int(id64)
		seats = append(seats, id)

		if id > max {
			max = id
		}
	}

	fmt.Printf("Part 1: %d\n", max)
	fmt.Printf("Part 2: %d\n", part2(seats))
}
