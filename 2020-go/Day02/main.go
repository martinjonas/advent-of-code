package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func isValid1(min, max int, target string, pass string) bool {
	count := strings.Count(pass, target)
	return min <= count && count <= max
}

func isValid2(pos1, pos2 int, target string, pass string) bool {
	c1 := pass[pos1-1]
	c2 := pass[pos2-1]
	return (c1 == target[0] || c2 == target[0]) && c1 != c2
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	valid1 := 0
	valid2 := 0

	for scanner.Scan() {
		line := scanner.Text()

		parts := strings.FieldsFunc(line, func(r rune) bool { return r == '-' || r == ' ' || r == ':' })
		n1, _ := strconv.Atoi(parts[0])
		n2, _ := strconv.Atoi(parts[1])
		target := parts[2]
		pass := parts[3]

		if isValid1(n1, n2, target, pass) {
			valid1++
		}

		if isValid2(n1, n2, target, pass) {
			valid2++
		}
	}

	fmt.Printf("Part 1: %d\n", valid1)
	fmt.Printf("Part 2: %d\n", valid2)
}
