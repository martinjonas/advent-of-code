package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Instruction struct {
	Op  string
	Arg int
}

func run(instructions []Instruction) (int, bool) {
	pc := 0
	acc := 0

	seen := make(map[int]bool)

	for pc < len(instructions) {
		if seen[pc] {
			return acc, false
		}

		seen[pc] = true

		current := instructions[pc]
		switch current.Op {
		case "acc":
			acc += current.Arg
			pc += 1
		case "jmp":
			pc += current.Arg
		case "nop":
			pc += 1
		default:
			panic(current.Op)
		}
	}

	return acc, true
}

func part1(instructions []Instruction) int {
	acc, terminated := run(instructions)
	if terminated {
		panic("Should not have terminated")
	}
	return acc
}

func part2(instructions []Instruction) int {
	for i, instr := range instructions {
		switch instr.Op {
		case "jmp":
			instructions[i] = Instruction{"nop", instr.Arg}
		case "nop":
			instructions[i] = Instruction{"jmp", instr.Arg}
		}

		acc, terminated := run(instructions)
		if terminated {
			return acc
		}

		instructions[i] = instr
	}

	return -1
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var lines []Instruction

	for scanner.Scan() {
		line := scanner.Text()

		parts := strings.Split(line, " ")
		arg, _ := strconv.Atoi(parts[1])
		lines = append(lines, Instruction{parts[0], arg})
	}

	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
