use core::cmp::{max, min};
use std::env;
use std::fs::read_to_string;

fn read_grid(filename: &str) -> Vec<Vec<char>> {
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn find_galaxies(grid: &[Vec<char>]) -> Vec<(isize, isize)> {
    let mut galaxies = Vec::new();
    for (y, row) in grid.iter().enumerate() {
        for (x, &ch) in row.iter().enumerate() {
            if ch == '#' {
                galaxies.push((x as isize, y as isize))
            }
        }
    }
    galaxies
}

fn find_empty_rows(grid: &[Vec<char>]) -> Vec<isize> {
    grid.iter()
        .enumerate()
        .filter(|&(_, row)| row.iter().all(|&ch| ch == '.'))
        .map(|(y, _)| y as isize)
        .collect()
}

fn find_empty_cols(grid: &[Vec<char>]) -> Vec<isize> {
    (0..grid[0].len())
        .filter(|&x| grid.iter().all(|row| row[x] == '.'))
        .map(|x| x as isize)
        .collect()
}

fn count_between(vals: &[isize], lower: isize, upper: isize) -> usize {
    vals.partition_point(|&x| x < upper) - vals.partition_point(|&x| x <= lower)
}

fn solve(grid: &[Vec<char>], expansion_factor: usize) -> usize {
    let galaxies = find_galaxies(grid);
    let mut empty_rows = find_empty_rows(grid);
    let mut empty_cols = find_empty_cols(grid);
    empty_rows.sort();
    empty_cols.sort();

    let to_add = expansion_factor - 1;

    let mut res = 0;
    for (i, &(x1, y1)) in galaxies.iter().enumerate() {
        for &(x2, y2) in &galaxies[i..] {
            res += (x1 - x2).unsigned_abs()
                + (y1 - y2).unsigned_abs()
                + to_add * count_between(&empty_cols, min(x1, x2), max(x1, x2))
                + to_add * count_between(&empty_rows, min(y1, y2), max(y1, y2))
        }
    }

    res
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let grid = read_grid(&filename);

    println!("Part 1: {}", solve(&grid, 2));
    println!("Part 2: {}", solve(&grid, 1000000));
}
