package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
)

func part1(containedIn map[string][]string) int {
	seen := make(map[string]bool)
	toProcess := []string{"shiny gold"}

	// DFS
	for len(toProcess) > 0 {
		current := toProcess[len(toProcess)-1]
		toProcess = toProcess[:len(toProcess)-1]

		for _, bag := range containedIn[current] {
			if seen[bag] {
				continue
			}

			seen[bag] = true
			toProcess = append(toProcess, bag)
		}
	}

	return len(seen)
}

func mustContain(bagName string, rules map[string]map[string]int, cache map[string]int) int {
	cachedResult, seen := cache[bagName]
	if seen {
		return cachedResult
	}

	result := 1
	for item, count := range rules[bagName]{
		result += count * mustContain(item, rules, cache)
	}

	cache[bagName] = result
	return result
}

func part2(rules map[string]map[string]int) int {
	cache := make(map[string]int)
	res := mustContain("shiny gold", rules, cache) - 1
	return res
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	rules := make(map[string]map[string]int)
	containedIn := make(map[string][]string)

	for scanner.Scan() {
		line := scanner.Text()
		line = strings.ReplaceAll(strings.ReplaceAll(line[:len(line)-1], " bags", ""), " bag", "")

		parts := strings.Split(line, " contain ")
		bagName := parts[0]
		bagStrings := strings.Split(parts[1], ", ")

		rule := make(map[string]int)
		for _, bagString := range bagStrings {
			if bagString == "no other" {
				continue
			}

			bagPair := strings.SplitN(bagString, " ", 2)
			innerCount, _ := strconv.Atoi(bagPair[0])
			innerName := bagPair[1]

			containedIn[innerName] = append(containedIn[innerName], bagName)

			rule[innerName] = innerCount
		}

		rules[bagName] = rule
	}

	fmt.Printf("Part 1: %d\n", part1(containedIn))
	fmt.Printf("Part 2: %d\n", part2(rules))
}
