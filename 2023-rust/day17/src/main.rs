use std::cmp::Reverse;
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::env;
use std::fs::read_to_string;

fn read_grid(filename: &str) -> Vec<Vec<i32>> {
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| {
            line.chars()
                .map(|s| s.to_digit(10).unwrap() as i32)
                .collect()
        })
        .collect()
}

#[derive(PartialEq, Eq, PartialOrd, Ord, Hash, Clone, Debug)]
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

    fn opposite(&self) -> Dir {
        match self {
            Dir::Up => Dir::Down,
            Dir::Right => Dir::Left,
            Dir::Down => Dir::Up,
            Dir::Left => Dir::Right,
        }
    }
}

fn search(grid: &[Vec<i32>], minsteps: Option<i32>, maxsteps: Option<i32>) -> i32 {
    let height = grid.len() as i32;
    let width = grid[0].len() as i32;

    let dirs = [Dir::Up, Dir::Right, Dir::Down, Dir::Left];

    let mut q = BinaryHeap::new();
    let mut closed: HashSet<((i32, i32), i32, Dir)> = HashSet::new();
    let mut dist: HashMap<((i32, i32), i32, Dir), i32> = HashMap::new();

    q.push(Reverse((0, (0, 0), 0, Dir::Right)));
    q.push(Reverse((0, (0, 0), 0, Dir::Down)));
    dist.insert(((0, 0), 0, Dir::Right), 0);
    dist.insert(((0, 0), 0, Dir::Down), 0);

    while let Some(Reverse((d, pos, straightsteps, dir))) = q.pop() {
        let (x, y) = pos;
        let key = (pos, straightsteps, dir.clone());
        if closed.contains(&key) {
            continue;
        }
        closed.insert(key);

        if x == width - 1 && y == height - 1 && straightsteps >= minsteps.unwrap_or(0) {
            return d;
        }

        for newdir in dirs.iter().filter(|d| **d != dir.opposite()) {
            let newpos = newdir.apply(pos);
            let (newx, newy) = newpos;
            if !(0..width).contains(&newx) || !(0..height).contains(&newy) {
                continue;
            }

            if let Some(min) = minsteps {
                if dir != *newdir && straightsteps < min {
                    continue;
                }
            }

            if let Some(max) = maxsteps {
                if dir == *newdir && straightsteps >= max {
                    continue;
                }
            }

            let newsteps = if dir == *newdir { straightsteps + 1 } else { 1 };
            let newdist = d + grid[newy as usize][newx as usize];

            let newkey = (newpos, newsteps, newdir.clone());
            if dist.get(&newkey).map_or(true, |d| d > &newdist) {
                dist.insert(newkey, newdist);
                q.push(Reverse((newdist, newpos, newsteps, newdir.clone())));
            }
        }
    }

    -1
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let grid = read_grid(&filename);

    println!("Part 1: {}", search(&grid, None, Some(3)));
    println!("Part 2: {}", search(&grid, Some(4), Some(10)));
}
