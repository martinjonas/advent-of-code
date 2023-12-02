use std::fs::read_to_string;
use std::str::FromStr;
use core::fmt::Debug;
use std::env;
use std::collections::HashMap;
use std::cmp::max;

fn read_lines<T: FromStr>(filename: &str) -> Vec<T> where
    <T as FromStr>::Err: Debug
{
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.parse::<T>().unwrap())
        .collect()
}

struct Turn {
    cubes: HashMap<String, u32>
}

struct Game {
    turns: Vec<Turn>
}

fn part1(games: &[Game]) -> u32 {
    let mut res = 0;
    for (n, game) in (1..).zip(games) {
        if let None = game.turns.iter().find(|turn| turn.cubes.get("red").unwrap_or(&0) > &12|| turn.cubes.get("green").unwrap_or(&0) > &13 || turn.cubes.get("blue").unwrap_or(&0) > &14) {
            res += n;
        }
    }
    res
}

fn part2(games: &[Game]) -> u32 {
    let mut res = 0;
    for game in games {
        let mut min_cubes : HashMap<String, u32> = HashMap::new();
        for turn in &game.turns {
            for (color, count) in &turn.cubes {
                min_cubes.entry(color.to_string()).and_modify(|cur_count| *cur_count = max(*cur_count, *count)).or_insert(*count);
            }
        }
        res += min_cubes.values().product::<u32>()
    }
    res
}

fn parse_turn(input: &str) -> Turn {
    let mut cubes = HashMap::new();
    for set in input.trim().split(',') {
        let mut parts = set.trim().split(' ');
        let num = parts.next().unwrap().parse::<u32>().unwrap();
        let name = parts.next().unwrap().to_string();
        cubes.insert(name, num);
    }
    Turn { cubes }
}


fn parse_game(input: &str) -> Game {
    let turn_strings = input.split(':').nth(1).unwrap();
    let turns = turn_strings.split(';').map(|s| parse_turn(s.trim())).collect();
    Game { turns }
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);
    let data : Vec<_> = input.iter().map(|l| parse_game(l)).collect();

    println!("Part 1: {}", part1(&data));
    println!("Part 2: {}", part2(&data));
}
