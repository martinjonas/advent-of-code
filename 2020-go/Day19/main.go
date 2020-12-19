package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func removeSimpleRules(rules map[string][][]string) map[string][][]string {
	// remove simple rules of from A → B
	// NOTE: this assumes that there are no chains of simple rules A → B; B → C
	withoutSimple := make(map[string][][]string)
	for lhs, rhs := range rules {
		withoutSimple[lhs] = [][]string{}

		for _, production := range rhs {
			if production[0][0] == '"' || len(production) == 2 {
				withoutSimple[lhs] = append(withoutSimple[lhs], production)					          } else if len(production) == 1 {
				withoutSimple[lhs] = append(withoutSimple[lhs], rules[production[0]]...)
			}
		}
	}

	return withoutSimple
}

func CYK(message string, rules map[string][][]string) bool {
	// This is the Cocke-Younger-Kasami algorithm I programmed at 6 AM
	// and thought it would be a good idea…
	var table [][](map[string]bool)

	for length := 0; length <= len(message); length++ {
		var row [](map[string]bool)
		for start := 0; start <= len(message)-length; start++ {
			cell := make(map[string]bool)
			row = append(row, cell)
		}
		table = append(table, row)
	}

	for length := 1; length <= len(message); length++ {
		for start := 0; start <= len(message)-length; start++ {
			if length == 1 {
				for lhs, productions := range rules {
					for _, production := range productions {
						if production[0][0] == '"' &&
							production[0][1:2] == message[start:start+length] {
							table[length][start][lhs] = true
							break
						}
					}
				}
			} else {
				for lhs, productions := range rules {
					for len1 := 1; len1 < length; len1++ {
						if table[length][start][lhs] {
							break
						}

						part1 := message[start:start+len1]
						part2 := message[start+len1:start+length]

						for _, production := range productions {
							if production[0][0] != '"' {
								leftOk := table[len(part1)][start][production[0]]
								rightOk := table[len(part2)][start+len1][production[1]]
								if leftOk && rightOk {
									table[length][start][lhs] = true
									break
								}
							}
						}
					}
				}
			}
		}
	}

	return table[len(message)][0]["0"]
}

type cacheIndex struct {
	message, nonterminal string
}

func recursiveDescent(message string, nonterm string, rules map[string][][]string, cache map[cacheIndex]bool) bool {
	// … but a simple recursive descent parser I wrote later turned out
	// to be simpler and faster
	ci := cacheIndex{message, nonterm}
	if cacheRes, inCache := cache[ci]; inCache {
		return cacheRes
	}

	for _, production := range rules[nonterm] {
		if len(production) == 1 {
			if production[0][0] == '"' {
				return message == production[0][1:2]
			} else {
				if recursiveDescent(message, production[0], rules, cache) {
					return true
				}
			}
		} else if len(production) == 2 {
			for len1 := 1; len1 < len(message); len1++ {
				part1 := message[0:len1]
				part2 := message[len1:]

				if recursiveDescent(part1, production[0], rules, cache) && recursiveDescent(part2, production[1], rules, cache) {
					cache[ci] = true
					return true
				}
			}
		} else {
			panic("Too long production rule.")
		}
	}

	cache[ci] = false
	return false
}

func countMatching(messages []string, rules map[string][][]string) int {
	result := 0
	rulesWithoutSimple := removeSimpleRules(rules)
	cache := make(map[cacheIndex]bool)

	for _, message := range messages {
		// one of the following would be enough, but since I have two parsers
		// I can at least check their results for consistency
		recursive := recursiveDescent(message, "0", rules, cache)
		cyk := CYK(message, rulesWithoutSimple)

		if recursive != cyk {
			fmt.Println(message, recursive, cyk)
			panic("Wrong, lol.")
		}

		if cyk {
			result++
		}
	}

	return result
}

func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	rules := make(map[string][][]string)
	var messages []string

	inRules := true
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			inRules = false
			continue
		}

		if inRules {
			parts := strings.Split(line, ": ")
			productions := strings.Split(parts[1], " | ")

			rules[parts[0]] = [][]string{}
			for _, production := range productions {
				nonterminals := strings.Split(production, " ")
				rules[parts[0]] = append(rules[parts[0]], nonterminals)
			}

		} else {
			messages = append(messages, line)
		}
	}

	fmt.Printf("Part 1: %d\n", countMatching(messages, rules))

	// PART 2:
	rules["8"] = [][]string{ {"42"}, {"42", "8"} }
	// the parsers work only for grammars in the Chomsky normal form
	// get rid of the production of lenght 3
	rules["11"] = [][]string{ {"42", "31"}, {"42", "hack"}}
	rules["hack"] = [][]string{ {"11", "31"} }
	fmt.Printf("Part 2: %d\n", countMatching(messages, rules))
}
