package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func apply_mask(n int, mask map[int]bool) int {
	for i, b := range mask {
		if b {
			n |= 1 << i
		} else {
			n = n &^ (1 << i)
		}
	}
	return n
}

func apply_decoder_mask(address int, mask map[int]bool) []int {
	var unknown_indices []int
	new_mask := make(map[int]bool)

	for i := 0; i < 36; i++ {
		b, isSet := mask[i]
		if b {
			new_mask[i] = true
		}
		if !isSet {
			unknown_indices = append(unknown_indices, i)
		}
	}

	possible := []int{}
	for v := 0; v < (1 << len(unknown_indices)); v++ {
		for  unknown_index, index := range unknown_indices {
			unknown_value := (v >> unknown_index) % 2 == 1
			new_mask[index] = unknown_value

		}
		possible = append(possible, apply_mask(address, new_mask))
	}

	return possible
}

func sum_map_values(m map[int]int) int {
	sum := 0
	for _, v := range m {
		sum += v
	}
	return sum
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	memory := make(map[int]int)
	memory2 := make(map[int]int)
	mask := make(map[int]bool)

	for scanner.Scan() {
		line := scanner.Text()

		if line[0:4] == "mask" {
			mask = make(map[int]bool)
			for i, b := range line[7:] {
				if b != 'X' {
					mask[35-i] = b == '1'
				}
			}
		} else {
			parts := strings.Split(line[4:], "] = ")
			index, _ := strconv.Atoi(parts[0])
			value, _ := strconv.Atoi(parts[1])

			memory[index] = apply_mask(value, mask)

			for _, address := range apply_decoder_mask(index, mask) {
				memory2[address] = value
			}
		}
	}

	fmt.Printf("Part 1: %d\n", sum_map_values(memory))
	fmt.Printf("Part 2: %d\n", sum_map_values(memory2))
}
