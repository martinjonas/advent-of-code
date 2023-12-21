use std::env;
use std::fs::read_to_string;
use std::collections::{HashSet,VecDeque,HashMap};

fn read_grid(filename: &str) -> Vec<Vec<char>> {
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn find_start(grid: &[Vec<char>]) -> Option<(i64, i64)> {
    for (y, row) in (0..).zip(grid) {
        for (x, &ch) in (0..).zip(row) {
            if ch == 'S' {
                return Some((x,y));
            }
        }
    }
    None
}

fn accelerate(mut remaining: i64, mut diffhistory: VecDeque<usize>, mut seconddiffhistory: VecDeque<usize>) -> usize {
    let mut res = 0;
    let looplen = diffhistory.len() as i64;

    for _ in 0..(remaining % looplen) {
        let d = diffhistory.pop_front().unwrap();
        let sd = seconddiffhistory.pop_front().unwrap();

        let new = d + sd;
        res += new;

        diffhistory.push_back(new);
        seconddiffhistory.push_back(sd);

        remaining -= 1;
    }

    let r = (remaining / looplen) as usize;
    let mut res = res as usize;
    res += r * diffhistory.iter().sum::<usize>();
    res += (r * (r + 1) * seconddiffhistory.iter().sum::<usize>()) / 2 as usize;
    res
}

fn part1(grid: &[Vec<char>], steps: i64) -> usize {
    let start = find_start(grid).unwrap();
    let height = grid.len() as i64;
    let width = grid[0].len() as i64;
    assert!(height == width);

    let mut reachable = HashSet::from([start]);

    // Conjecture: There is a loop of length height (or width)
    // The additions increase linearly in each iteration of the loop
    let mut diffs = VecDeque::from(vec![0; (height+1) as usize]);
    let mut seconddiffs = VecDeque::from(vec![0; height as usize]);

    let mut seen: HashMap<VecDeque<usize>, i64> = HashMap::new();

    let mut prev = 0;
    for i in 1..=steps {
        reachable = reachable.iter()
            .flat_map(|&(x,y)| [(x+1, y), (x-1, y), (x, y+1), (x, y-1)])
            .filter(|&(x,y)|
                    grid[y.rem_euclid(height) as usize][x.rem_euclid(width) as usize] == '.' ||
                    grid[y.rem_euclid(height) as usize][x.rem_euclid(width) as usize] == 'S')
            .collect();
        let cur = reachable.len();
        diffs.pop_front();
        diffs.push_back(cur-prev);
        seconddiffs.pop_front();
        seconddiffs.push_back(diffs.back().unwrap() - diffs.front().unwrap());
        prev = cur;

        if seen.contains_key(&seconddiffs) {
            diffs.pop_front();
            return cur + accelerate(steps - i, diffs, seconddiffs)
        } else {
            seen.insert(seconddiffs.clone(), i);
        }
    }

    reachable.len()
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let grid = read_grid(&filename);

    println!("Part 1: {}", part1(&grid, 64));
    println!("Part 1: {}", part1(&grid, 26501365));
}
