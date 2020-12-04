package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
)

func isValid1(passport map[string]string) bool {
	_, cidPresent := passport["cid"]
	return len(passport) == 8 || (len(passport) == 7 && !cidPresent)
}

func part1(passports [](map[string]string)) int {
	valid := 0
	for _, passport := range passports {
		if isValid1(passport) {
			valid++
		}
	}

	return valid
}

func isNumberBetween(s string, min, max int) bool {
	num, _ := strconv.Atoi(s)
	return min <= num && num <= max
}

// DISCLAIMER: I am really not proud about the following code…
func isValid2(passport map[string]string) bool {
	if !isValid1(passport) {
		return false
	}

	// byr (Birth Year) - four digits; at least 1920 and at most 2002.
	// iyr (Issue Year) - four digits; at least 2010 and at most 2020.
	// eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
	// hgt (Height) - a number followed by either cm or in:
	//     If cm, the number must be at least 150 and at most 193.
	//     If in, the number must be at least 59 and at most 76.
	// hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
	// ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
	// pid (Passport ID) - a nine-digit number, including leading zeroes.
	// cid (Country ID) - ignored, missing or not.

	if !isNumberBetween(passport["byr"], 1920, 2002) ||
		!isNumberBetween(passport["iyr"], 2010, 2020) ||
		!isNumberBetween(passport["eyr"], 2020, 2030) {
		return false
	}

	hgt := passport["hgt"]
	if strings.HasSuffix(hgt, "cm") {
		if !isNumberBetween(strings.TrimSuffix(hgt, "cm"), 150, 193) {
			return false
		}
	} else if strings.HasSuffix(hgt, "in") {
		if !isNumberBetween(strings.TrimSuffix(hgt, "in"), 59, 76) {
			return false
		}
	} else {
		return false
	}

	hcl := passport["hcl"]
	if len(hcl) != 7 || hcl[0] != '#' {
		return false
	}

	for _, r := range hcl[1:] {
		if (r < '0' || r > '9') && (r < 'a' || r > 'f') {
			return false
		}
	}

	ecl := passport["ecl"]
	if (ecl != "amb" && ecl != "blu" && ecl != "brn" && ecl != "gry" && ecl != "grn" && ecl != "hzl" && ecl != "oth") {
		return false
	}

	pid := passport["pid"]
	if len(pid) != 9 {
		return false
	}

	for _, r := range pid {
		if (r < '0' || r > '9'){
			return false
		}
	}

	return true
}

func part2(passports [](map[string]string)) int {
	valid := 0
	for _, passport := range passports {
		if isValid2(passport) {
			valid++
		}
	}

	return valid
}


func main() {
	file, _ := os.Open("input")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var passports [](map[string]string)

	passports = append(passports, make(map[string]string))
	for scanner.Scan() {
		line := scanner.Text()

		if line == "" {
			passports = append(passports, make(map[string]string))
			continue
		}

		parts := strings.Split(line, " ")
		for _, part := range parts {
			fields := strings.Split(part, ":")
			passports[len(passports) - 1][fields[0]] = fields[1]
		}
	}

	fmt.Printf("Part 1: %d\n", part1(passports))
	fmt.Printf("Part 2: %d\n", part2(passports))
}
