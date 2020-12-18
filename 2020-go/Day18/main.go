package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func tokenize(input string) []string {
	var tokens []string

	var tok_start int
	for i, r := range input {
		if r == ' ' {
			if tok_start != i {
				tokens = append(tokens, input[tok_start:i])
			}
			tok_start = i+1
		} else if r == '(' || r == ')' || r == '+' || r == '*' {
			if tok_start != i {
				tokens = append(tokens, input[tok_start:i])
			}
			tokens = append(tokens, input[i:i+1])
			tok_start = i+1
		}
	}

	if tok_start != len(input) {
		tokens = append(tokens, input[tok_start:])
	}

	return tokens
}

func apply(nums []int, ops []string) ([]int, []string)  {
	op := ops[len(ops)-1]
	arg1 := nums[len(nums) - 2]
	arg2 := nums[len(nums) - 1]

	switch op {
	case "+": nums = append(nums[:len(nums) - 2], arg1 + arg2)
	case "*": nums = append(nums[:len(nums) - 2], arg1 * arg2)
	default: panic(op)
	}

	return nums, ops[:len(ops)-1]
}

func eval(input string, priorities map[string]int) int {
	tokens := tokenize(input)

	// Shunting-yard with on-the-fly evaluation of the result
	var numbers []int
	var ops []string

	for _, token := range tokens {
		if n, err := strconv.Atoi(token); err == nil {
			numbers = append(numbers, n)
		} else if token == "(" {
			ops = append(ops, token)
		} else if priority, isOp := priorities[token]; isOp {
			for len(ops) > 0 && ops[len(ops)-1] != "(" && priorities[ops[len(ops)-1]] >= priority {
				numbers, ops = apply(numbers, ops)
			}
			ops = append(ops, token)
		} else if token == ")" {
			for ops[len(ops)-1] != "(" {
				numbers, ops = apply(numbers, ops)
			}
			ops = ops[:len(ops)-1]
		} else {
			panic(token)
		}
	}

	for len(ops) > 0 {
		numbers, ops = apply(numbers, ops)
	}

	return numbers[0]
}

func sumResults(lines []string, priorities map[string]int) int {
	result := 0
	for _, line := range lines {
		result += eval(line, priorities)
	}
	return result
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

	fmt.Printf("Part 1: %d\n", sumResults(lines, map[string]int{ "+": 0, "*": 0 }))
	fmt.Printf("Part 2: %d\n", sumResults(lines, map[string]int{ "+": 1, "*": 0 }))
}
