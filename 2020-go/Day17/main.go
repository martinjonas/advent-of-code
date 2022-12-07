package main

import (
	"bufio"
	"fmt"
	"os"
)

type position struct {
	x,y,z,w int
}

var(
	dir = [3]int{-1, 0, 1}
)

func getNeighbors(pos position, wdiffs []int) []position {
	var neighbors []position
	for _, dx := range dir {
		for _, dy := range dir {
			for _, dz := range dir {
				for _, dw := range wdiffs {
					if dx == 0 && dy == 0 && dz == 0 && dw == 0 {
						continue
					}

					neighbor := position{pos.x+dx, pos.y+dy, pos.z+dz, pos.w+dw}
					neighbors = append(neighbors, neighbor)
				}
			}
		}
	}

	return neighbors
}

func countActiveNeighbors(state map[position]bool, pos position, wdiffs []int) int {
	result := 0

	for _, neighbor := range getNeighbors(pos, wdiffs) {
		if state[neighbor] {
			result++
		}
	}

	return result
}

func step(state map[position]bool, wdiffs []int) map[position]bool {
	newPlan := make(map[position]bool)

	for pos := range state {
		for _, neighbor := range getNeighbors(pos, wdiffs) {
			if !state[neighbor] {
				state[neighbor] = false
			}
		}
	}

	for pos, active := range state {
		activeNeighbors := countActiveNeighbors(state, pos, wdiffs)

		if (active && (activeNeighbors == 2 || activeNeighbors == 3)) ||
			(!active && activeNeighbors == 3) {
			newPlan[pos] = true
		}
	}

	return newPlan
}

func run(plan map[position]bool, steps int, wdiffs []int) int {
	current := plan
	for i := 0; i < steps; i++ {
		current = step(current, wdiffs)
	}

	return len(current)
}

func part1(plan map[position]bool) int {
	return run(plan, 6, []int{0})
}

func part2(plan map[position]bool) int {
	return run(plan, 6, []int{-1, 0, 1})
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	initial := make(map[position]bool)

	y := 0
	for scanner.Scan() {
		line := scanner.Text()

		for x, r := range line {
			if r == '#' {
				initial[position{x, y, 0, 0}] = true
			}
		}

		y++
	}

	fmt.Printf("Part 1: %d\n", part1(initial))
	fmt.Printf("Part 2: %d\n", part2(initial))
}
