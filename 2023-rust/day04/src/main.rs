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
    let mut res = 0;

    for line in input {
        let data = line.split(':').nth(1).unwrap().trim();

        let mut parts = data.split('|');
        let winning: Vec<_> = parts.next().unwrap().trim().split_whitespace().map(|s| s.parse::<u32>().unwrap()).collect();
        let have: Vec<_> = parts.next().unwrap().trim().split_whitespace().map(|s| s.parse::<u32>().unwrap()).collect();

        let count = have.iter().filter(|c| winning.contains(c)).count() as u32;
        if count > 0 {
            let base: u32 = 2;
            res += base.pow(count - 1);
        }
    }

    res
}

fn part2(input: &[String]) -> u32 {
    let mut cards = vec![1; input.len()];
    let mut i = 0;

    for line in input {
        let data = line.split(':').nth(1).unwrap().trim();

        let mut parts = data.split('|');
        let winning: Vec<_> = parts.next().unwrap().trim().split_whitespace().map(|s| s.parse::<u32>().unwrap()).collect();
        let have: Vec<_> = parts.next().unwrap().trim().split_whitespace().map(|s| s.parse::<u32>().unwrap()).collect();

        let count = have.iter().filter(|c| winning.contains(c)).count() as u32;
        for j in 1..=count {
          cards[i+j as usize] += cards[i];
        }
        i += 1
    }

    cards.iter().sum::<u32>()
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);

    println!("Part 1: {}", part1(&input));
    println!("Part 2: {}", part2(&input));
}
