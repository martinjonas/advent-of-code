package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

type tile struct {
	id int
	image [][]bool
}

func reverseBoolSlice(input []bool) []bool {
	output := make([]bool, len(input))

	for i, b := range input {
		output[len(output)-1-i] = b
	}

	return output
}

func getBorders(tile [][]bool) [][]bool {
	var borders [][]bool

	borders = append(borders, tile[0])

	var rightBorder []bool
	for _, line := range tile {
		rightBorder = append(rightBorder, line[len(line)-1])
	}
	borders = append(borders, rightBorder)

	borders = append(borders, tile[len(tile)-1])

	var leftBorder []bool
	for _, line := range tile {
		leftBorder = append(leftBorder, line[0])
	}
	borders = append(borders, leftBorder)

	return borders
}

type border struct {
	tile int
	index int
	flipX bool
	content []bool
}

func fromBinary(border []bool) int {
	key := 0

	offset := 1
	for _, b := range border {
		if b {
			key += offset
		}

		offset *= 2
	}

	return key
}

type orientedTile struct {
	tile int
	flipX bool
	rotation int
}

type pos struct {
	x, y int
}

const (
	T = iota
	R
	B
	L
)

func getUnassigned(tiles map[int]tile, assigned map[int]orientedTile, rotate bool) []orientedTile {
	var result []orientedTile

	for _, tile := range tiles {
		_, isAssigned := assigned[tile.id]

		if !isAssigned {
			maxRotate := 0
			if rotate {
				maxRotate = 3
			}

			for r := 0; r <= maxRotate; r++ {
				result = append(result,
					orientedTile{tile.id, false, r},
					orientedTile{tile.id, true, r})
			}
		}
	}

	return result
}

func rotateBorders(borders [][]bool) [][]bool {
	var newBorders [][]bool
	newBorders = append(newBorders, borders[R], borders[B], borders[L], borders[T])
	newBorders[R], newBorders[L] = reverseBoolSlice(newBorders[R]), reverseBoolSlice(newBorders[L])

	return newBorders
}

func getRotatedBorders(tiles map[int]tile, tile orientedTile) [][]bool {
	defaultBorders := getBorders(tiles[tile.tile].image)
	var borders [][]bool

	borders = append(borders, defaultBorders...)

	if tile.flipX {
		borders[T], borders[B] = reverseBoolSlice(borders[T]), reverseBoolSlice(borders[B])
		borders[R], borders[L] = borders[L], borders[R]
	}

	for i := 0; i < tile.rotation; i++ {
		borders = rotateBorders(borders)
	}

	return borders
}

func eqBorders(l []bool, r []bool) bool {
	for i, lb := range l {
		if lb != r[i] {
			return false
		}
	}

	return true
}

func buildMatching(tiles map[int]tile, trace map[pos]orientedTile, assigned map[int]orientedTile, assignPos pos) (bool, map[pos]orientedTile) {
	if len(assigned) == len(tiles) {
		return true, trace
	}

	squareSize := int(math.Sqrt(float64(len(tiles))))

	possibilities := getUnassigned(tiles, assigned, true)

	for _, toAssign := range possibilities {
		assignedBorders := getRotatedBorders(tiles, toAssign)

		if assignPos.x != 0 {
			tileLeft := trace[pos{assignPos.x - 1, assignPos.y}]
			borderLeft := getRotatedBorders(tiles, tileLeft)[R]

			if !eqBorders(assignedBorders[L], borderLeft) {
				continue
			}
		}

		if assignPos.y != 0 {
			tileAbove := trace[pos{assignPos.x, assignPos.y-1}]
			borderAbove := getRotatedBorders(tiles, tileAbove)[B]

			if !eqBorders(assignedBorders[T], borderAbove) {
				continue
			}
		}

		trace[assignPos] = toAssign
		assigned[toAssign.tile] = toAssign

		var nextpos pos

		if assignPos.y == squareSize - 1 {
			nextpos = pos{ assignPos.y, assignPos.x+1 }
		} else if assignPos.x == 0 {
			nextpos = pos{ assignPos.y+1, 0 }
		} else {
			nextpos = pos{ assignPos.x-1, assignPos.y+1 }
		}

		if ok, newMatching := buildMatching(tiles, trace, assigned, nextpos); ok {
			return true, newMatching
		}

		delete(trace, assignPos)
		delete(assigned, toAssign.tile)
	}

	return false, nil
}

func part1(tiles map[int]tile) (int, map[pos]orientedTile) {
	allRotations := getUnassigned(tiles, make(map[int]orientedTile), true)

	borderMap := make(map[int]map[int]bool)
	for _, rotation := range allRotations {
		assignedBorders := getRotatedBorders(tiles, rotation)
		for _, border := range assignedBorders {
			key := fromBinary(border)
			if _, inMap := borderMap[key]; !inMap {
				borderMap[key] = make(map[int]bool)
			}
			borderMap[key][rotation.tile] = true
		}
	}

	possibleNeighbors := make(map[orientedTile][][]int)

	for _, rotation := range allRotations {
		assignedBorders := getRotatedBorders(tiles, rotation)
		for _, border := range assignedBorders {
			key := fromBinary(border)
			var withoutCurrentTile []int
			for neighbor := range borderMap[key] {
				if neighbor != rotation.tile {
					withoutCurrentTile = append(withoutCurrentTile, neighbor)
				}
			}
			possibleNeighbors[rotation] = append(possibleNeighbors[rotation], withoutCurrentTile)
		}
	}

	mustBeCorners := make(map[int]bool)

	for tile := range tiles {
		mustBeCorners[tile] = true
	}

	for rotation, neighbors := range possibleNeighbors {
		sidesWithoutNeighbors := 0
		for _, sideNeighbors := range neighbors {
			if len(sideNeighbors) == 0 {
				sidesWithoutNeighbors++
			}
		}
		if sidesWithoutNeighbors <= 1 {
			delete(mustBeCorners, rotation.tile)
		}
	}

	//var someCorner int
	result := 1
	for corner := range mustBeCorners {
		//someCorner = corner
		result *= corner
	}

	for rot := 0; rot < 4; rot++ {
		assigned := make(map[int]orientedTile)
		trace := make(map[pos]orientedTile)
		//trace[pos{0,0}] = orientedTile{someCorner, false, false, rot}
		//assigned = make(map[int]orientedTile)
		//assigned[someCorner] = orientedTile{someCorner, false, false, 0}
		ok, trace := buildMatching(tiles, trace, assigned, pos{0,0})

		if ok {
			return result, trace
		}
	}

	return -1, nil
}

func rotateCord(size int, x int, y int) (int, int, int) {
	return size, y, size-1-x
}

func getRotatedTile(image [][]bool, flipX bool, rot int) [][]bool {
	size := len(image)
	newImage := make([][]bool, size)
	for y := 0; y < size; y++ {
		newImage[y] = make([]bool, size)
	}

	for y := 0; y < size; y++ {
		for x := 0; x < size; x++ {
			transX, transY := x, y

			if flipX {
				transX = size-1-transX
			}

			for i := 0; i < rot; i++ {
				_, transX, transY = rotateCord(size, transX, transY)
			}

			newImage[transY][transX] = image[y][x]
		}
	}
	return newImage
}

func monsterPositions() ([]pos, int, int) {
	monster := []string{
		"                  # ",
		"#    ##    ##    ###",
		" #  #  #  #  #  #   "}

	var monsterPositions []pos
	for y, line := range monster {
		for x, r := range line {
			if r == '#' {
				monsterPositions = append(monsterPositions, pos{x, y})
			}
		}
	}

	return monsterPositions, len(monster), len(monster[1])
}

func findMonsters(image [][]bool) int {
	size := len(image)
	newImage := make([][]bool, size)
	for y := 0; y < size; y++ {
		newImage[y] = make([]bool, size)
	}

	monster, monsterH, monsterW := monsterPositions()
	monsterCount := 0

	for y := 0; y + monsterH - 1 < size; y++ {
		for x := 0; x + monsterW - 1 < size; x++ {
			isMonster := true

			for _, pos := range monster {
				if !image[y+pos.y][x+pos.x] {
					isMonster = false
					break
				}
			}

			if isMonster {
				monsterCount++
				for _, pos := range monster {
					image[y+pos.y][x+pos.x] = false
				}
			}
		}
	}

	safeWaters := 0
	for y := 0; y < size; y++ {
		for x := 0; x < size; x++ {
			if image[y][x] {
				safeWaters++
			}
		}
	}

	return safeWaters
}

func findRotatedMonsters(image [][]bool) int {
	minSafeWaters := -1

	for rot := 0; rot < 4; rot++ {
		for _, flipX := range []bool{false, true} {
			safeWaters := findMonsters(getRotatedTile(image, flipX, rot))

			if minSafeWaters == -1 || safeWaters < minSafeWaters {
				minSafeWaters = safeWaters
			}
		}
	}

	return minSafeWaters
}

func part2(tileSize int, tiles map[int]tile, tiling map[pos]orientedTile) int {
	size := int(math.Sqrt(float64(len(tiles))))

	plan := make([][]bool, (tileSize-2)*size)
	for i := 0; i < len(plan); i++ {
		plan[i] = make([]bool, (tileSize-2)*size)
	}

	for tilePos, assignedTile := range tiling {
		image := getRotatedTile(tiles[assignedTile.tile].image,
		 	assignedTile.flipX, assignedTile.rotation)
		for y, line := range image[1:len(image)-1] {
			for x, assigned := range line[1:len(line)-1]  {
				if assigned {
					plan[tilePos.y*(tileSize-2) + y][tilePos.x*(tileSize-2) + x] = true
				}
			}
		}
	}

	return findRotatedMonsters(plan)
}

func main() {
	fileBytes, _ := ioutil.ReadFile("input")

	tileStrings := strings.Split(string(fileBytes), "\n\n")

	tiles := make(map[int]tile)
	tileSize := 0
	for _, tileString := range tileStrings {
		tileLines := strings.Split(tileString, "\n")
		id, _ := strconv.Atoi(tileLines[0][5:len(tileLines[0])-1])

		var imageLines [][]bool
		for _, line := range tileLines[1:] {
			var imageLine []bool
			for _, r := range line {
				if r == '#' {
					imageLine = append(imageLine, true)
				} else if r == '.' {
					imageLine = append(imageLine, false)
				} else {
					panic(r)
				}
			}
			imageLines = append(imageLines, imageLine)
		}

		tiles[id] = tile{id, imageLines}
		tileSize = len(imageLines)
	}

	p1, tiling := part1(tiles)
	fmt.Printf("Part 1: %d\n", p1)
	fmt.Printf("Part 2: %d\n", part2(tileSize, tiles, tiling))
}
