use std::fs::read_to_string;
use std::str::FromStr;
use core::fmt::Debug;
use std::env;
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

#[derive(Debug)]
struct ConditionRecord {
    condition: Vec<char>,
    groups: Vec<u64>
}

fn parse_record(input: &str) -> ConditionRecord {
    let mut parts = input.split(' ');
    let condition: Vec<_> = parts.next().unwrap().chars().collect();
    let groups: Vec<_> = parts.next().unwrap().split(',').map(|s| s.parse::<u64>().unwrap()).collect();

    ConditionRecord { condition, groups }
}

fn count_damaged(condition: &[char], groups: &[u64], from_cond: usize, from_group: usize, cache: &mut HashMap<(usize, usize), u64>) -> u64 {
    if from_group == groups.len() {
        return 0;
    }

    let next_damaged = groups[from_group] as usize;
    if condition.len() - from_cond < next_damaged || condition.iter().skip(from_cond).take(next_damaged).any(|&ch| ch == '.') {
        return 0;
    }

    if condition.len() - from_cond == next_damaged {
        if groups.len() - from_group == 1 { 1 } else { 0 }
    } else if condition[from_cond + next_damaged] == '#' {
        0
    } else {
        count(condition, groups, from_cond + next_damaged + 1, from_group + 1, cache)
    }
}

fn count(condition: &[char], groups: &[u64], from_cond: usize, from_group: usize, cache: &mut HashMap<(usize, usize), u64>) -> u64 {
    if let Some(&res) = cache.get(&(from_cond, from_group)) {
        return res;
    }

    if from_cond == condition.len() {
        return if from_group == groups.len() { 1 } else { 0 };
    }

    let res = match condition[from_cond] {
        '.' => count(condition, groups, from_cond + 1, from_group, cache),
        '#' => count_damaged(condition, groups, from_cond, from_group, cache),
        '?' => count(condition, groups, from_cond + 1, from_group, cache) +
            count_damaged(condition, groups, from_cond, from_group, cache),
        _ => unreachable!()
    };

    cache.insert((from_cond, from_group), res);
    res
}

fn part1(records: &[ConditionRecord]) -> u64 {
    records.iter().map(|r| count(&r.condition, &r.groups, 0, 0, &mut HashMap::new())).sum()
}

fn unfold(rec: &ConditionRecord) -> ConditionRecord {
    let mut condition = Vec::new();
    let mut groups = Vec::new();
    condition.extend(rec.condition.iter());
    groups.extend(rec.groups.iter());
    for _ in 0..4 {
        condition.push('?');
        condition.extend(rec.condition.iter());
        groups.extend(rec.groups.iter());
    }
    ConditionRecord { condition, groups }
}

fn part2(records: &[ConditionRecord]) -> u64 {
    let unfolded: Vec<_> = records.iter().map(unfold).collect();
    part1(&unfolded)
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);
    let data: Vec<_> = input.into_iter().map(|l| parse_record(&l)).collect();

    println!("Part 1: {}", part1(&data));
    println!("Part 2: {}", part2(&data));
}
