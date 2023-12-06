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

struct Card {
    winning: Vec<u32>,
    have: Vec<u32>
}

fn parse_card (s: &str) -> Card {
    let parts = s.split(':').nth(1).unwrap().trim().split('|');
    let mut numbers = parts.map(|p| p.split_whitespace().map(|s| s.parse::<u32>().unwrap()).collect());
    let (Some(winning), Some(have)) = (numbers.next(), numbers.next()) else { panic!() };

    Card { winning, have }
}

fn part1(cards: &[Card]) -> u32 {
    cards.iter()
        .map(|card| card.have.iter().filter(|c| card.winning.contains(c)).count())
        .filter(|&count| count > 0)
        .map(|count| 1 << (count - 1))
        .sum()
}

fn part2(cards: &[Card]) -> u32 {
    let mut card_counts = vec![1; cards.len()];

    for (i, card) in cards.iter().enumerate() {
        let count = card.have.iter().filter(|c| card.winning.contains(c)).count() as u32;
        for j in 1..=count {
            card_counts[i+j as usize] += card_counts[i];
        }
    }

    card_counts.iter().sum::<u32>()
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);
    let data: Vec<Card> = input.iter().map(|l| parse_card(l)).collect();

    println!("Part 1: {}", part1(&data));
    println!("Part 2: {}", part2(&data));
}
