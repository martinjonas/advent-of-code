use std::fs::read_to_string;
use std::str::FromStr;
use core::fmt::Debug;
use std::env;
use std::cmp::PartialOrd;
use std::cmp::Ordering;
use std::collections::HashMap;

fn read_lines<T: FromStr>(filename: &str) -> Vec<T> where
    <T as FromStr>::Err: Debug
{
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.parse::<T>().unwrap())
        .collect()
}

#[derive(PartialEq, Eq, PartialOrd, Ord, Debug, Hash, Clone)]
enum Card {
    J,
    Number(u32),
    T,
    Q,
    K,
    A
}

fn to_card(ch: char) -> Card {
    match ch {
        'T' => Card::T,
        'J' => Card::J,
        'Q' => Card::Q,
        'K' => Card::K,
        'A' => Card::A,
        _ => Card::Number(ch.to_digit(10).unwrap())
    }
}

#[derive(Debug, Clone)]
struct Hand {
    cards: Vec<Card>,
    bid: u32
}

fn counts (h: &Vec<Card>) -> Vec<u32> {
    let mut counts: HashMap<&Card, u32> = HashMap::new();
    let mut jokers = 0;
    for c in h {
        if *c == Card::J {
            jokers += 1;
            continue
        }
        counts.entry(c).and_modify(|counts| *counts += 1).or_insert(1);
    }

    let mut res: Vec<u32> = counts.values().cloned().collect();
    res.sort();
    res.reverse();
    if res.is_empty() {
        res.push(0);
    }
    res[0] += jokers;
    res
}

fn cmp_hands(l: &Vec<Card>, r: &Vec<Card>) -> Ordering {
    let lc = counts(l);
    let rc = counts(r);

    match lc.cmp(&rc) {
        std::cmp::Ordering::Less => std::cmp::Ordering::Less,
        std::cmp::Ordering::Greater => std::cmp::Ordering::Greater,
        std::cmp::Ordering::Equal => l.cmp(r)
    }
}

fn parse_card (s: &str) -> Hand {
    let mut parts = s.split(' ');

    Hand {
        cards: parts.next().unwrap().chars().map(|ch| to_card(ch)).collect(),
        bid: parts.next().unwrap().parse::<u32>().unwrap() }
}

fn part2(hands: Vec<Hand>) -> u32 {
    let mut h = hands.clone();
    h.sort_by(|l, r| cmp_hands(&l.cards, &r.cards));
    (1..).zip(h).map(|(rank, hand)| rank * hand.bid).sum::<u32>()
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);
    let hands: Vec<Hand> = input.iter().map(|s| parse_card(s)).collect();

    println!("Part 2: {}", part2(hands));
}
