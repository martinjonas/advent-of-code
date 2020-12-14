package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func apply_mask(n int, mask map[int]bool) int {
	res := n
	for i, b := range mask {
		if b {
			res |= 1 << i
		} else {
			res = res &^ (1 << i)
		}
	}
	return res
}

func apply_decoder_mask(address int, mask map[int]bool) []int {
	res := address

	unknown_indices := make(map[int]int)
	unknown := 0

	for i := 0; i < 36; i++ {
		b, isSet := mask[i]
		if isSet {
			if b {
				res |= 1 << i
			}
		} else {
			unknown_indices[i] = unknown
			unknown++
		}
	}

	possible := []int{}
	for v := 0; v < (1 << unknown); v++ {
		to_add := res
		for index, unknown_index := range unknown_indices {
			unknown_value := (v >> unknown_index) % 2 == 1

			if unknown_value {
				to_add |= 1 << index
			} else {
				to_add = to_add &^ (1 << index)
			}
		}
		possible = append(possible, to_add)
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
