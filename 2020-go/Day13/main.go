package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"math/big"
)

func part1(target int, busIds []int) int {
	min := target
	minId := 0

	for _, busId := range busIds {
		if busId != 0 {
			current := busId - target % busId
			if current < min {
				min = current
				minId = busId
			}
		}
	}

	return min * minId
}

func part2(target int, busIds []int) int {
	current := 0
	step := 1

	for i, busId := range busIds {
		if busId != 0 {
			currentTarget := busId - i

			// solve "current + x*step == currentTarget (mod busId)" for x
			// x = (currentTarget - current)*(step^{-1}) (mod busId)

			// difference = (currentTarget - current)
			difference := (currentTarget - current + busId) % busId

			// compute (step^{-1}) (mod busId)
			var necessarySteps big.Int
			necessarySteps.ModInverse(big.NewInt(int64(step)), big.NewInt(int64(busId)))

			// add x*step, which is (currentTarget - current)*(step^{-1})*step
			// the inversion of step does not cancel out, as it is computed modulo busId
			// and we are working modulo lcm of bus intervals
			current += difference * int(necessarySteps.Int64()) * step

			step *= busId
		}
	}

	return current % step
}


func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var lines []string

	for scanner.Scan() {
		line := scanner.Text()

		lines = append(lines, line)
	}

	target, _ := strconv.Atoi(lines[0])
	var busIds []int

	for _, busId := range strings.Split(lines[1], ",") {
		intId, _ := strconv.Atoi(busId)
		busIds = append(busIds, intId)
	}

	fmt.Printf("Part 1: %d\n", part1(target, busIds))
	fmt.Printf("Part 2: %d\n", part2(target, busIds))
}
