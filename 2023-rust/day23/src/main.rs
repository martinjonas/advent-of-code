use std::collections::{HashMap, HashSet, VecDeque};
use std::env;
use std::fs::read_to_string;

fn read_grid(filename: &str) -> Vec<Vec<char>> {
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

type Point = (i32, i32);

fn get_neighbors(grid: &[Vec<char>], p: Point, ignore_slippery: bool) -> Vec<Point> {
    let (x, y) = p;
    let height = grid.len() as i32;
    let width = grid[0].len() as i32;

    if ignore_slippery {
        [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
            .into_iter()
            .filter(|&(x, y)| {
                x >= 0 && x < width && y >= 0 && y < height && grid[y as usize][x as usize] != '#'
            })
            .collect()
    } else {
        let res: Vec<Point> = match grid[y as usize][x as usize] {
            '>' => vec![(x + 1, y)],
            '<' => vec![(x - 1, y)],
            'v' => vec![(x, y + 1)],
            '^' => vec![(x, y - 1)],
            '.' => vec![(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)],
            _ => unreachable!(),
        };
        res.into_iter()
            .filter(|&(x, y)| {
                x >= 0 && x < width && y >= 0 && y < height && grid[y as usize][x as usize] != '#'
            })
            .collect()
    }
}

fn find_nearest_crossroads(
    grid: &[Vec<char>],
    start: Point,
    end: Point,
    ignore_slippery: bool,
) -> Vec<(Point, i32)> {
    let mut result = Vec::new();

    let mut to_process = VecDeque::from([(start, 0)]);
    let mut seen: HashSet<Point> = HashSet::from([start]);

    while let Some((cur, d)) = to_process.pop_front() {
        let neighbors = get_neighbors(grid, cur, ignore_slippery);
        if cur != start && (neighbors.len() > 2 || cur == end) {
            result.push((cur, d));
            continue;
        }

        for n in neighbors {
            if !seen.contains(&n) {
                seen.insert(n);
                to_process.push_back((n, d + 1));
            }
        }
    }

    result
}

type Graph = HashMap<Point, Vec<(Point, i32)>>;

fn get_compressed_graph(
    grid: &[Vec<char>],
    start: Point,
    target: Point,
    ignore_slippery: bool,
) -> Graph {
    let mut result = HashMap::new();

    let mut to_process = vec![start];
    let mut seen = HashSet::from([start]);

    while let Some(cur) = to_process.pop() {
        let nearest = find_nearest_crossroads(grid, cur, target, ignore_slippery);
        result.insert(cur, nearest.clone());
        for (n, _) in nearest {
            if !seen.contains(&n) {
                to_process.push(n);
                seen.insert(n);
            }
        }
    }

    result
}

fn find_longest_path_rec(g: &Graph, from: Point, to: Point, seen: &mut HashSet<Point>) -> i32 {
    if from == to {
        return 0;
    }

    let mut res = -1;
    seen.insert(from);
    for (succ, d) in &g[&from] {
        if seen.contains(succ) {
            continue;
        }

        let dist = find_longest_path_rec(g, *succ, to, seen);
        let newdist = dist + d;
        if dist != -1 && newdist > res {
            res = newdist;
        }
    }
    seen.remove(&from);
    res
}

fn find_longest_path(g: &Graph, from: Point, to: Point) -> i32 {
    let mut seen = HashSet::new();
    find_longest_path_rec(g, from, to, &mut seen)
}

fn solve(grid: &[Vec<char>], ignore_slippery: bool) -> i32 {
    let height = grid.len() as i32;
    let width = grid[0].len() as i32;
    let start = (1, 0);
    let target = (width - 2, height - 1);

    let g = get_compressed_graph(grid, start, target, ignore_slippery);
    find_longest_path(&g, start, target)
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let grid = read_grid(&filename);

    println!("Part 1: {}", solve(&grid, false));
    println!("Part 2: {}", solve(&grid, true));
}
