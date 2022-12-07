package main

import (
	"fmt"
	"strconv"
	"strings"
	"container/list"
	"io/ioutil"
)

func copyList(in list.List) *list.List {
	result := list.New()

	for temp := in.Front(); temp != nil; temp = temp.Next() {
		result.PushBack(temp.Value)
	}

	return result
}

func copyListN(in list.List, n int) *list.List {
	result := list.New()

	i := 0
	for temp := in.Front(); temp != nil; temp = temp.Next() {
		if i >= n {
			break
		}

		i++
		result.PushBack(temp.Value)
	}

	return result
}

func play(deck1, deck2 *list.List) *list.List {
	for deck1.Len() > 0 && deck2.Len() > 0 {
		p1 := deck1.Front()
		p2 := deck2.Front()

		p1Val := p1.Value.(int)
		p2Val := p2.Value.(int)

		if p1Val > p2Val {
			deck1.PushBack(p1Val)
			deck1.PushBack(p2Val)
		} else {
			deck2.PushBack(p2Val)
			deck2.PushBack(p1Val)
		}

		deck1.Remove(p1)
		deck2.Remove(p2)
	}

	if deck1.Len() > 0 {
		return deck1
	} else {
		return deck2
	}
}

func deckScore(deck *list.List) int {
	i := 1
	result := 0
	for temp := deck.Back(); temp != nil; temp = temp.Prev() {
		result += i * temp.Value.(int)
		i++
	}

	return result
}

func part1(deck1, deck2 *list.List) int {
	return deckScore(play(copyList(*deck1), copyList(*deck2)))
}

func listsToString(in1 *list.List, in2 *list.List) string {
	var items []string

	for temp := in1.Front(); temp != nil; temp = temp.Next() {
		items = append(items, fmt.Sprint(temp.Value.(int)))
	}

	items = append(items, ";")

	for temp := in2.Front(); temp != nil; temp = temp.Next() {
		items = append(items, fmt.Sprint(temp.Value.(int)))
	}

	return strings.Join(items, " ")
}

func playRec(deck1, deck2 *list.List) (int, *list.List) {
	seen := make(map[string]bool)

	for deck1.Len() > 0 && deck2.Len() > 0 {
		key := listsToString(deck1, deck2)
		if seen[key] {
			return 1, deck1
		}
		seen[key] = true

		p1 := deck1.Front()
		p2 := deck2.Front()

		p1Val := p1.Value.(int)
		p2Val := p2.Value.(int)

		deck1.Remove(p1)
		deck2.Remove(p2)

		winner := 0
		if deck1.Len() >= p1Val && deck2.Len() >= p2Val {
			winner, _ = playRec(copyListN(*deck1, p1Val), copyListN(*deck2, p2Val))
		} else if p1Val > p2Val {
			winner = 1
		}

		if winner == 1 {
			deck1.PushBack(p1Val)
			deck1.PushBack(p2Val)
		} else {
			deck2.PushBack(p2Val)
			deck2.PushBack(p1Val)
		}
	}

	if deck1.Len() > 0 {
		return 1, deck1
	} else {
		return 2, deck2
	}
}

func part2(deck1, deck2 *list.List) int {
	_, winningDeck := playRec(copyList(*deck1), copyList(*deck2))
	return deckScore(winningDeck)
}

func main() {
	fileBytes, _ := ioutil.ReadFile("input")

	decks := strings.Split(string(fileBytes), "\n\n")

	deck1 := list.New()
	deck2 := list.New()

	for _, line := range strings.Split(decks[0], "\n")[1:] {
		i, _ := strconv.Atoi(line)
		deck1.PushBack(i)
	}

	for _, line := range strings.Split(decks[1], "\n")[1:] {
		i, _ := strconv.Atoi(line)
		deck2.PushBack(i)
	}

	fmt.Printf("Part 1: %d\n", part1(deck1, deck2))
	fmt.Printf("Part 2: %d\n", part2(deck1, deck2))
}
