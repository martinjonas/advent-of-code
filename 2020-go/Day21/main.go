package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"sort"
)

type alergen = string
type ingredient = string

type food struct {
	ingredients []ingredient
	alergens []alergen
}

func sliceToMap(strings []string) map[string]bool {
	result := make(map[string]bool)
	for _, s := range strings {
		result[s] = true
	}
	return result
}

func getSomeKey(m map[string]bool) string {
	var result string
	for s := range m {
		result = s
		break
	}
	return result
}

func part1(foods []food) (int, map[alergen]ingredient) {
	canBeIn := make(map[alergen](map[ingredient]bool))

	for _, food := range foods {
		for _, a := range food.alergens {
			foodIngredients := sliceToMap(food.ingredients)

			if allergenPossibilities, seen := canBeIn[a]; seen {
				for i := range allergenPossibilities {
					if _, ok := foodIngredients[i]; !ok {
						delete(allergenPossibilities, i)
					}
				}
			} else {
				canBeIn[a] = foodIngredients
			}
		}
	}

	assignment := make(map[alergen]ingredient)
	fixedIngredients := make(map[ingredient]bool)

	for len(canBeIn) > 0 {
		found := false

		for a, possibilities := range canBeIn {
			if len(possibilities) == 1 {
				i := getSomeKey(possibilities)
				assignment[a] = i
				fixedIngredients[i] = true

				delete(canBeIn, a)
				for _, l := range canBeIn {
					delete(l, i)
				}

				found = true
				break
			}
		}

		if !found {
			panic("Could not be uniquely assigned; more general approach needed. :(")
		}
	}

	result := 0
	for _, food := range foods {
		for _, i := range food.ingredients {
			if _, isFixed := fixedIngredients[i]; !isFixed {
				result++
			}
		}
	}

	return result, assignment
}

func part2(assignment map[alergen]ingredient) string {
	var alergens []alergen
	for a := range assignment {
		alergens = append(alergens, a)
	}

	sort.Strings(alergens)

	var dangerous []ingredient
	for _, a := range alergens {
		dangerous = append(dangerous, assignment[a])
	}
	return strings.Join(dangerous, ",")
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var foods []food

	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, " (")

		foods = append(foods,
			food{strings.Split(parts[0], " "),
				strings.Split(parts[1][9:len(parts[1])-1], ", ")},
		)
	}

	p1, assingment := part1(foods)
	fmt.Printf("Part 1: %d\n", p1)
	fmt.Printf("Part 2: %s\n", part2(assingment))
}
