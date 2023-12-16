use std::cmp::max;
use std::collections::HashSet;
use std::env;
use std::fs::read_to_string;
use std::hash::Hash;

fn read_grid(filename: &str) -> Vec<Vec<char>> {
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

#[derive(PartialEq, Eq, Hash, Clone)]
enum Dir {
    Up,
    Right,
    Down,
    Left,
}

impl Dir {
    fn apply(&self, (x, y): (i32, i32)) -> (i32, i32) {
        match self {
            Dir::Up => (x, y - 1),
            Dir::Right => (x + 1, y),
            Dir::Down => (x, y + 1),
            Dir::Left => (x - 1, y),
        }
    }
}

fn apply_slash(dir: &Dir) -> Dir {
    match dir {
        Dir::Up => Dir::Right,
        Dir::Right => Dir::Up,
        Dir::Down => Dir::Left,
        Dir::Left => Dir::Down,
    }
}

fn apply_backslash(dir: &Dir) -> Dir {
    match dir {
        Dir::Up => Dir::Left,
        Dir::Right => Dir::Down,
        Dir::Down => Dir::Right,
        Dir::Left => Dir::Up,
    }
}

fn energizes(grid: &[Vec<char>], x: i32, y: i32, dir: Dir) -> usize {
    let start = ((x, y), dir);

    let mut to_process = Vec::new();
    let mut seen = HashSet::new();
    to_process.push(start.clone());
    seen.insert(start);

    let height = grid.len();
    let width = grid[0].len();
    let is_valid =
        |(x, y)| (0..height).contains(&(y as usize)) && (0..width).contains(&(x as usize));

    while let Some((pos, dir)) = to_process.pop() {
        let mut step_and_add = |(pos, dir): ((i32, i32), Dir)| {
            let next = dir.apply(pos);
            if is_valid(next) && !seen.contains(&(next, dir.clone())) {
                to_process.push((next, dir.clone()));
                seen.insert((next, dir));
            }
        };

        let (x, y) = pos;
        let ch = grid[y as usize][x as usize];
        match (ch, &dir) {
            ('/', _) => step_and_add((pos, apply_slash(&dir))),
            ('\\', _) => step_and_add((pos, apply_backslash(&dir))),
            ('|', Dir::Right | Dir::Left) => {
                step_and_add((pos, Dir::Up));
                step_and_add((pos, Dir::Down));
            }
            ('-', Dir::Up | Dir::Down) => {
                step_and_add((pos, Dir::Left));
                step_and_add((pos, Dir::Right));
            }
            _ => step_and_add((pos, dir)),
        }
    }

    seen.iter().map(|s| s.0).collect::<HashSet<_>>().len()
}

fn part1(grid: &[Vec<char>]) -> usize {
    energizes(grid, 0, 0, Dir::Right)
}

fn part2(grid: &[Vec<char>]) -> usize {
    let height = grid.len() as i32;
    let width = grid[0].len() as i32;

    let mut res = 0usize;
    for y in 0..height {
        res = max(res, energizes(grid, 0, y, Dir::Right));
        res = max(res, energizes(grid, width - 1, y, Dir::Left));
    }
    for x in 0..width {
        res = max(res, energizes(grid, x, 0, Dir::Down));
        res = max(res, energizes(grid, x, height - 1, Dir::Up));
    }
    res
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let grid = read_grid(&filename);

    println!("Part 1: {}", part1(&grid));
    println!("Part 2: {}", part2(&grid));
}
