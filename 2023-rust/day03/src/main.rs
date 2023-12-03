use std::fs::read_to_string;
use std::str::FromStr;
use core::fmt::Debug;
use std::env;
use std::collections::{HashSet,HashMap};

fn read_lines<T: FromStr>(filename: &str) -> Vec<T> where
    <T as FromStr>::Err: Debug
{
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.parse::<T>().unwrap())
        .collect()
}

struct NumberMap {
    numbers: Vec<u32>,
    number_positions: HashMap<(i32, i32), usize>
}

impl NumberMap {
    fn from_input (input: &[Vec<char>]) -> Self {
        let mut numbers = Vec::new();
        let mut number_positions = HashMap::new();

        for (row, line) in (0..).zip(input.iter()) {
            let mut lineiter = (0..).zip(line.iter());
            loop {
                let number_chars = lineiter.by_ref()
                    .skip_while(|(_col, c)| !c.is_ascii_digit())
                    .take_while(|(_col, c)| c.is_ascii_digit());
                let (columns, digits) : (Vec<i32>, Vec<char>) = number_chars.unzip();

                if columns.len() > 0 {
                    numbers.push(digits.iter().collect::<String>().parse::<u32>().unwrap());

                    let number_index = numbers.len() - 1;
                    (columns[0]..=columns[columns.len()-1]).for_each(|c| { number_positions.insert((c, row), number_index); })
                } else {
                    break;
                }
            }
        }

        NumberMap{numbers, number_positions}
    }
}

fn get_positions_where<F>(input: &[Vec<char>], f: F) -> Vec<(i32, i32)>
    where F: Fn(char) -> bool
{
    (0..).zip(input.iter())
        .flat_map(|(row, line)|
                  (0..)
                  .zip(line.iter())
                  .filter(|(_col, c)| f(**c))
                  .map(move |(col, _c)| (col, row)))
        .collect()
}

fn part1(input: &[Vec<char>]) -> u32 {
    let number_map = NumberMap::from_input(input);
    let symbols = get_positions_where(input, |c| c != '.' && !c.is_ascii_digit());

    let mut numbers_with_neighbor = HashSet::new();
    for (col, row) in symbols {
        for dc in [-1, 0, 1] {
            for dr in [-1, 0, 1] {
                if let Some(&index) = number_map.number_positions.get(&(col + dc, row + dr)) {
                    numbers_with_neighbor.insert(index);
                }
            }
        }
    }

    numbers_with_neighbor.iter().map(|&i| number_map.numbers[i]).sum()
}

fn part2(input: &[Vec<char>]) -> u32 {
    let number_map = NumberMap::from_input(input);
    let gears = get_positions_where(input, |c| c == '*');

    let mut res = 0;
    for (c, r) in gears {
        let mut neighbors = HashSet::new();
        for dc in [-1, 0, 1] {
            for dr in [-1, 0, 1] {
                if let Some(&index) = number_map.number_positions.get(&(c + dc, r + dr)) {
                    neighbors.insert(index);
                }
            }
        }

        if neighbors.len() == 2 {
            res += neighbors.iter().map(|&i| number_map.numbers[i]).product::<u32>();
        }
    }

    res
}


fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input: Vec<Vec<_>> = read_lines::<String>(&filename)
        .iter()
        .map(|line| line.chars().collect()).collect();

    println!("Part 1: {}", part1(&input));
    println!("Part 2: {}", part2(&input));
}
