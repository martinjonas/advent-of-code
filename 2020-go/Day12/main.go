package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func Abs(x int) int {
	if x < 0 {
		return -x
	}

	return x
}

type action struct {
	command rune
	val int
}

func rotate_dir_left_90(dir rune) rune {
	switch dir {
	case 'N': return 'W'
	case 'E': return 'N'
	case 'S': return 'E'
	case 'W': return 'S'
	}

	panic(dir)
}

func rotate_dir_left(dir rune, degrees int) rune {
	switch degrees {
	case 90:
		return rotate_dir_left_90(dir)
	case 180:
		return rotate_dir_left_90(rotate_dir_left_90(dir))
	case 270:
		return rotate_dir_left_90(rotate_dir_left_90(rotate_dir_left_90(dir)))
	}

	panic(degrees)
}


func part1(actions []action) int {
	east, north := 0, 0
	dir := 'E'

	for _, a := range actions {
		switch a.command {
		case 'N': north += a.val
		case 'S': north -= a.val
		case 'E': east += a.val
		case 'W': east -= a.val
		case 'L': dir = rotate_dir_left(dir, a.val)
		case 'R': dir = rotate_dir_left(dir, 360 - a.val)
		case 'F':
			switch dir {
			case 'N': north += a.val
			case 'E': east += a.val
			case 'S': north -= a.val
			case 'W': east -= a.val
			}
		}

	}

	return Abs(north) + Abs(east)
}

func rotate_point_left_90(e int, n int) (int, int) {
	return -n, e
}

func rotate_point_left(e int, n int, degrees int) (int, int) {
	switch degrees {
	case 90:
		return rotate_point_left_90(e, n)
	case 180:
		return rotate_point_left_90(rotate_point_left_90(e, n))
	case 270:
		return rotate_point_left_90(rotate_point_left_90(rotate_point_left_90(e, n)))
	}

	panic(degrees)
}

func part2(actions []action) int {
	east, north := 10, 1
	ship_east, ship_north := 0, 0

	for _, a := range actions {
		switch a.command {
		case 'N': north += a.val
		case 'S': north -= a.val
		case 'E': east += a.val
		case 'W': east -= a.val
		case 'L': east, north = rotate_point_left(east, north, a.val)
		case 'R': east, north = rotate_point_left(east, north, 360 - a.val)
		case 'F':
			ship_east += a.val*east
			ship_north += a.val*north
		}
	}

	return Abs(ship_north) + Abs(ship_east)
}


func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var actions []action

	for scanner.Scan() {
		line := scanner.Text()

		dir := rune(line[0])
		val, _ := strconv.Atoi(line[1:])
		actions = append(actions, action{dir, val})
	}

	fmt.Printf("Part 1: %d\n", part1(actions))
	fmt.Printf("Part 2: %d\n", part2(actions))
}
