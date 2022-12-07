package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
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

var (
	hclRegex = regexp.MustCompile("^#[0-9a-f]{6}$")
	eclRegex = regexp.MustCompile("^(amb|blu|brn|gry|grn|hzl|oth)$")
	pidRegex = regexp.MustCompile("^[0-9]{9}$")
)

func isValidField(key, value string) bool {
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

	switch key {
	case "byr":
		return isNumberBetween(value, 1920, 2002)
	case "iyr":
		return isNumberBetween(value, 2010, 2020)
	case "eyr":
		return isNumberBetween(value, 2020, 2030)
	case "hgt":
		if strings.HasSuffix(value, "cm") {
			return isNumberBetween(strings.TrimSuffix(value, "cm"), 150, 193)
		} else if strings.HasSuffix(value, "in") {
			return isNumberBetween(strings.TrimSuffix(value, "in"), 59, 76)
		} else {
			return false
		}
	case "hcl":
		return hclRegex.MatchString(value)
	case "ecl":
		return eclRegex.MatchString(value)
	case "pid":
		return pidRegex.MatchString(value)
	case "cid":
		return true
	}

	return false
}

func part2(passports [](map[string]string)) int {
	valid := 0
	for _, passport := range passports {
		if !isValid1(passport) {
			continue
		}

		isValid := true
		for k,v := range passport {
			isValid = isValid && isValidField(k,v)
		}

		if isValid {
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
