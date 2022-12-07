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

func part2(busIds []int) int {
	current, step := 0, 1

	for i, modulo := range busIds {
		if modulo != 0 {
			currentTarget := modulo - i

			// solve "current + x*step == currentTarget (mod modulo)" for x
			// x = (currentTarget - current)*(step^{-1}) (mod modulo)

			// difference = (currentTarget - current)
			difference := (currentTarget - current + modulo) % modulo

			// compute (step^{-1}) (mod modulo)
			var necessarySteps big.Int
			necessarySteps.ModInverse(big.NewInt(int64(step)), big.NewInt(int64(modulo)))

			// add x*step, which is (currentTarget - current)*(step^{-1})*step
			// the inversion of step does not cancel out, as it is computed modulo modulo
			// and we are working modulo lcm of bus intervals
			current += difference * int(necessarySteps.Int64()) * step

			step *= modulo
		}
	}

	return current % step
}

func part2_sieve(busIds []int) int {
	// I swear that this did not work when I tried the sieving method
	// in the morning…
	current, step := 0, 1

	for target, modulo := range busIds {
		if modulo != 0 {
			for (- target - current) % modulo != 0 {
				current += step
			}
			step *= modulo
		}
	}

	return current
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
	fmt.Printf("Part 2: %d\n", part2(busIds))
	fmt.Printf("Part 2 (sieve): %d\n", part2_sieve(busIds))
}
