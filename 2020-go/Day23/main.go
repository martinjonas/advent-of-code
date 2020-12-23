package main

import (
	"container/ring"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func doMoves(numbers *ring.Ring, moves int) *ring.Ring {
	len := numbers.Len()

	numberToNode := make(map[int]*ring.Ring)
	for i := 0; i < len; i++ {
		number := numbers.Value.(int)
		numberToNode[number] = numbers
		numbers = numbers.Next()
	}

	for i := 0; i < moves; i++ {
		c1 := numbers.Next()
		c2 := c1.Next()
		c3 := c2.Next()

		currentVal := numbers.Value.(int)
		targetVal := currentVal - 1

		if targetVal == 0 {
			targetVal = len
		}

		for targetVal == c1.Value.(int) || targetVal == c2.Value.(int) || targetVal == c3.Value.(int) {
			if targetVal == 1 {
				targetVal = len
			} else {
				targetVal--
			}
		}

		destination := numberToNode[targetVal]

		numbers.Unlink(3)
		destination.Link(c1)

		numbers = numbers.Next()
	}

	return numberToNode[1]
}

func part1(numbers *ring.Ring) string {
	numbers = doMoves(numbers, 100)
	numbers = numbers.Next()

	result := ""
	for i := 0; i < numbers.Len() - 1; i++ {
		result += fmt.Sprintf("%d", numbers.Value.(int))
		numbers = numbers.Next()
	}

	return result
}

func part2(numbers *ring.Ring) int {
	numbers = doMoves(numbers, 10000000)
	numbers = numbers.Next()

	n1 := numbers.Value.(int)
	n2 := numbers.Next().Value.(int)

	return n1*n2
}


func main() {
	fileBytes, _ := ioutil.ReadFile("input")
	cups := strings.Split(string(fileBytes), "")

	var numbers, numbers2 *ring.Ring

	numbers = ring.New(len(cups))
	numbers2 = ring.New(1000000)
	for _, cup := range cups {
		number, _ := strconv.Atoi(cup)
		numbers.Value = number
		numbers = numbers.Next()
		numbers2.Value = number
		numbers2 = numbers2.Next()
	}

	fmt.Printf("Part 1: %s\n", part1(numbers))

	l := numbers.Len()
	toAdd := numbers2.Len() - numbers.Len()
	for i := 0; i < toAdd; i++ {
		numbers2.Value = i + l + 1
		numbers2 = numbers2.Next()
	}

	fmt.Printf("Part 2: %d\n", part2(numbers2))
}
