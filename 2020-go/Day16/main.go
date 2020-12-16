package main

import (
	"io/ioutil"
	"fmt"
	"strings"
	"strconv"
)

type Interval struct {
	from, to int
}

func (i Interval) Contains(val int) bool {
	return i.from <= val && val <= i.to
}

func InAnyInterval(value int, intervals []Interval) bool {
	for _, interval := range intervals {
		if interval.Contains(value) {
			return true
		}
	}
	return false
}

func IntSliceFromString(str string) []int {
	var result []int
	for _, field := range strings.Split(str, ",") {
		value, _ := strconv.Atoi(field)
		result = append(result, value)
	}
	return result
}

func ParseRule(str string) (string, []Interval) {
	parts := strings.Split(str, ": ")

	var intervals []Interval
	for _, interval := range strings.Split(parts[1], " or ") {
		bounds := strings.Split(interval, "-")
		lower, _ := strconv.Atoi(bounds[0])
		upper, _ := strconv.Atoi(bounds[1])

		intervals = append(intervals, Interval{lower, upper})
	}

	return parts[0], intervals
}

func main() {
	file, _ := ioutil.ReadFile("input")
	groups := strings.Split(string(file), "\n\n")

	rules := make(map[string][]Interval)
	var allIntervals []Interval

	for _, line := range strings.Split(groups[0], "\n") {
		field, intervals := ParseRule(line)
		rules[field] = intervals
		allIntervals = append(allIntervals, intervals...)
	}

	var part1 int
	var validNearby [][]int
	for _, line := range strings.Split(groups[2], "\n")[1:] {
		values := IntSliceFromString(line)

		valid := true
		for _, value := range values {
			if !InAnyInterval(value, allIntervals) {
				valid = false
				part1 += value
			}
		}

		if valid {
			validNearby = append(validNearby, values)
		}
	}

	fmt.Printf("Part 1: %d\n", part1)

	part2 := 1
	myTicket := IntSliceFromString(strings.Split(groups[1], "\n")[1])

	possibleMaps := make(map[int](map[string]bool))

	for i := range myTicket {
		possibleMaps[i] = make(map[string]bool)
		for field := range rules {
			possibleMaps[i][field] = true
		}
	}

	for _, ticket := range validNearby {
		for i, value := range ticket {
			for field, intervals := range rules {
				if !InAnyInterval(value, intervals) {
					delete(possibleMaps[i], field)
				}
			}
		}
	}

	for len(possibleMaps) > 0 {
		assignedIndex := -1
		assignedField := ""

		for field, possibleFields := range possibleMaps {
			for possibleField := range possibleFields {
				assignedField = possibleField
				break
			}

			if len(possibleFields) == 1 {
				assignedIndex = field
				break
			}
		}

		if strings.HasPrefix(assignedField, "departure") {
			part2 *= myTicket[assignedIndex]
		}

		delete(possibleMaps, assignedIndex)
		for _, possibleFields := range possibleMaps {
			delete(possibleFields,assignedField)
		}
	}

	fmt.Printf("Part 2: %d\n", part2)
}
