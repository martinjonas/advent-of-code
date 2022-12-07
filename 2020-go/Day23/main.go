package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func doMoves(current, max int, nextMap []int, moves int) []int {
	for i := 0; i < moves; i++ {
		c1 := nextMap[current]
		c2 := nextMap[c1]
		c3 := nextMap[c2]

		destination := current - 1

		if destination == 0 {
			destination = max
		}

		for destination == c1 || destination == c2 || destination == c3 {
			if destination == 1 {
				destination = max
			} else {
				destination--
			}
		}

		afterc3 := nextMap[c3]
		nextMap[c3] = nextMap[destination]
		nextMap[destination] = c1
		nextMap[current] = afterc3

		current = nextMap[current]
	}

	return nextMap
}

func part1(current, max int, nextMap []int) string {
	nextMap = doMoves(current, max, nextMap, 100)

	toProcess := nextMap[1]
	result := ""
	for i := 0; i < max - 1; i++ {
		result += fmt.Sprintf("%d", toProcess)
		toProcess = nextMap[toProcess]
	}

	return result
}

func part2(current, max int, nextMap []int) int {
	nextMap = doMoves(current, max, nextMap, 10000000)
	return nextMap[1] * nextMap[nextMap[1]]
}

func getNextMap(cupNumbers []int) []int {
	nextMap := make([]int, len(cupNumbers) + 1)
	for i := range cupNumbers {
		nextMap[cupNumbers[i]] = cupNumbers[(i + 1) % len(cupNumbers)]
	}
	return nextMap
}

func main() {
	fileBytes, _ := ioutil.ReadFile("input")
	cups := strings.Split(string(fileBytes), "")

	var cupNumbers []int
	var max int

	for _, cup := range cups {
		number, _ := strconv.Atoi(cup)
		cupNumbers = append(cupNumbers, number)

		if number > max {
			max = number
		}
	}

	nextMap := getNextMap(cupNumbers)
	fmt.Printf("Part 1: %s\n", part1(cupNumbers[0], max, nextMap))

	for i := max + 1; i <= 1000000; i++ {
		cupNumbers = append(cupNumbers, i)
	}

	nextMap = getNextMap(cupNumbers)
	fmt.Printf("Part 2: %d\n", part2(cupNumbers[0], 1000000, nextMap))
}
