use std::fs::read_to_string;
use std::str::FromStr;
use core::fmt::Debug;
use std::env;
use std::collections::{HashSet,HashMap};
use std::iter::Iterator;

fn read_lines<T: FromStr>(filename: &str) -> Vec<T> where
    <T as FromStr>::Err: Debug
{
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.parse::<T>().unwrap())
        .collect()
}

struct CartesianProductIterator<ItL: Iterator, ItR: Iterator+Clone> {
    it_l: ItL,
    it_r: ItR,
    cur_l: Option<ItL::Item>,
    begin_r: ItR,
}

impl<ItL: Iterator, ItR: Iterator+Clone> CartesianProductIterator<ItL, ItR> {
    fn new(it_l: ItL, it_r: ItR) -> Self {
        CartesianProductIterator { it_l, it_r: it_r.clone(), cur_l: None, begin_r: it_r }
    }
}

impl<ItL: Iterator, ItR: Iterator+Clone> Iterator for CartesianProductIterator<ItL, ItR> where
    <ItL as Iterator>::Item: Clone
{
    type Item = (ItL::Item, ItR::Item);

    fn next(&mut self) -> Option<Self::Item> {
        if self.cur_l.is_none() {
            self.cur_l = self.it_l.next();
            if self.cur_l.is_none() {
                return None
            }
        }

        match self.it_r.next() {
            Some(r) => Some((self.cur_l.clone().unwrap(), r)),
            None => match self.it_l.next() {
                None => None,
                Some(l) => {
                    self.cur_l = Some(l);
                    self.it_r = self.begin_r.clone();
                    self.next()
                }
            }
        }
    }
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

                if columns.is_empty() {
                    break
                }

                numbers.push(digits.iter().collect::<String>().parse::<u32>().unwrap());

                let number_index = numbers.len() - 1;
                (columns[0]..=columns[columns.len()-1]).for_each(|c| { number_positions.insert((c, row), number_index); })
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
        CartesianProductIterator::new([-1, 0, 1].iter(), [-1, 0, 1].iter())
            .filter_map(|(dc, dr)|number_map.number_positions.get(&(col + dc, row + dr)))
            .for_each(|&index| { numbers_with_neighbor.insert(index); })
    }

    numbers_with_neighbor.iter().map(|&i| number_map.numbers[i]).sum()
}

fn part2(input: &[Vec<char>]) -> u32 {
    let number_map = NumberMap::from_input(input);
    let gears = get_positions_where(input, |c| c == '*');

    let mut res = 0;
    for (c, r) in gears {
        let neighbors: HashSet<_> = CartesianProductIterator::new([-1, 0, 1].iter(), [-1, 0, 1].iter())
            .filter_map(|(dc, dr)|number_map.number_positions.get(&(c + dc, r + dr)))
            .cloned()
            .collect();

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
