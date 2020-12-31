package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type pos struct {
	col, row int
}

func tileToPos(tile string) pos {
	var current pos
	for _, r := range tile {
		switch r {
		case 'w': current.col -= 2
		case 'e': current.col += 2
		case '1':
			current.col--
			current.row++
		case '2':
			current.col++
			current.row++
		case '3':
			current.col--
			current.row--
		case '4':
			current.col++
			current.row--
		default:
			panic(r)
		}
	}

	return current
}

func part1(lines []string) (int, map[pos]bool) {
	isBlack := make(map[pos]bool)

	for _, line := range lines {
		pos := tileToPos(line)
		if isBlack[pos] {
			delete(isBlack, pos)
		} else {
			isBlack[pos] = true
		}
	}

	return len(isBlack), isBlack
}

var neighbors = [6]pos{ {2,0}, {-2,0}, {1,1}, {1,-1}, {-1,1}, {-1,-1} }

func countNeighbors(target pos, state map[pos]bool) int {
	result := 0

	for _, n := range neighbors {
		if state[pos{target.col + n.col, target.row + n.row}] {
			result++
		}
	}

	return result
}

func makeFalseNeighborsExplicit(target pos, state map[pos]bool) {
	for _, n := range neighbors {
		nPos := pos{target.col + n.col, target.row + n.row}
		if !state[nPos] {
			state[nPos] = false
		}
	}
}

func step(state map[pos]bool) map[pos]bool{
	newState := make(map[pos]bool)

	for pos := range state {
		makeFalseNeighborsExplicit(pos, state)
	}

	for pos, isBlack := range state {
		newIsBlack := isBlack

		blackNeighbors := countNeighbors(pos, state)
		if isBlack && (blackNeighbors == 0 || blackNeighbors > 2) {
			newIsBlack = false
		} else if !isBlack && blackNeighbors == 2 {
			newIsBlack = true
		}

		if newIsBlack {
			newState[pos] = true
		}
	}

	return newState
}

func part2(isBlack map[pos]bool) int {
	for i := 0; i < 100; i++ {
		isBlack = step(isBlack)
	}

	return len(isBlack)
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var lines []string

	// Ugly hack, I know…
	replacer := strings.NewReplacer("nw", "1", "ne", "2", "sw", "3", "se", "4")

	for scanner.Scan() {
		line := replacer.Replace(scanner.Text())
		lines = append(lines, line)
	}

	p1, isBlack := part1(lines)
	fmt.Printf("Part 1: %d\n", p1)
	fmt.Printf("Part 2: %d\n", part2(isBlack))
}
