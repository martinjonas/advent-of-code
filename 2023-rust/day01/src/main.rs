use std::fs::read_to_string;
use std::str::FromStr;
use core::fmt::Debug;
use std::env;

fn read_lines<T: FromStr>(filename: &str) -> Vec<T> where
    <T as FromStr>::Err: Debug
{
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.parse::<T>().unwrap())
        .collect()
}

fn part1(input: &[String]) -> u32 {
    let mut res: u32 = 0;
    for line in input {
        let digits: Vec<u32> = line.chars().filter_map(|ch| ch.to_digit(10)).collect();
        res += 10*digits.first().unwrap() + digits.last().unwrap();
    }
    res
}

static NUMERALS : [&str; 9] = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];

fn part2(input: &[String]) -> u32 {
    let mut res: u32 = 0;
    for line in input {
        let mut digits = Vec::<u32>::new();
        for i in 0..line.len() {
            let prefix = &line[i..line.len()];
            for (v, n) in (1..).zip(NUMERALS) {
                if prefix.starts_with(n) { digits.push(v) };
            }

            let first = prefix.chars().next().unwrap();
            if let Some(d) = first.to_digit(10) {
                digits.push(d)
            }
        }

        res += 10*digits.first().unwrap() + digits.last().unwrap();
    }
    res
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);

    println!("Part 1: {}", part1(&input));
    println!("Part 2: {}", part2(&input));
}
