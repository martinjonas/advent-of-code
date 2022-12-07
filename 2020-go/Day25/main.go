package main

import (
	"fmt"
)

const (
	modulus = 20201227
	subject_number = 7
)

func discrete_log(input int, base int) int {
	result := 1
	i := 0

	for result != input {
		i++
		result = (result * base) % modulus
	}

	return i
}

func fast_power(input int, base int) int {
	if input == 0 {
		return 1
	} else if input % 2 == 0 {
		resHalf := fast_power(input/2, base)
		return (resHalf * resHalf) % modulus
	} else {
		resHalf := fast_power(input/2, base)
		return (resHalf * (resHalf * base % modulus)) % modulus
	}
}

func part1(door_public int, card_public int) int {
	door_private := discrete_log(door_public, subject_number)
	encKey := fast_power(door_private, card_public)
	return encKey
}

func main() {
	door_public := 18499292
	card_public := 8790390
	fmt.Printf("Part 1: %d\n", part1(door_public, card_public))
}
