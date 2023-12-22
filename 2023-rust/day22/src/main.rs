use core::fmt::Debug;
use std::collections::HashSet;
use std::env;
use std::fs::read_to_string;
use std::str::FromStr;

fn read_lines<T: FromStr>(filename: &str) -> Vec<T>
where
    <T as FromStr>::Err: Debug,
{
    read_to_string(filename)
        .expect("file reading error")
        .lines()
        .map(|line| line.parse::<T>().unwrap())
        .collect()
}

#[derive(Debug, PartialEq, Eq, Hash, Clone)]
struct Brick {
    x1: i32,
    y1: i32,
    z1: i32,
    x2: i32,
    y2: i32,
    z2: i32,
}

fn supports(below: &Brick, above: &Brick) -> bool {
    below.z2 + 1 == above.z1
        && below.x1 <= above.x2
        && below.x2 >= above.x1
        && below.y1 <= above.y2
        && below.y2 >= above.y1
}

fn is_supported(b: &Brick, bricks: &[Brick]) -> bool {
    b.z1 == 1 || bricks.iter().any(|b2| supports(b2, b))
}

fn parse_brick(s: &str) -> Brick {
    let parts = s
        .split('~')
        .map(|p| {
            p.split(',')
                .map(|v| v.parse::<i32>().unwrap())
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();
    match &parts[..] {
        [p1, p2] => Brick {
            x1: p1[0],
            y1: p1[1],
            z1: p1[2],
            x2: p2[0],
            y2: p2[1],
            z2: p2[2],
        },
        _ => panic!(),
    }
}

fn make_fall(bricks: &mut Vec<Brick>) {
    for i in 0..bricks.len() {
        while !is_supported(&bricks[i], bricks) {
            bricks[i].z1 -= 1;
            bricks[i].z2 -= 1;
        }
    }
}

fn part1(supports_map: &[Vec<usize>], supported_by_map: &[Vec<usize>]) -> usize {
    let mut necessary = HashSet::new();
    for support_set in supported_by_map {
        if support_set.len() == 1 {
            necessary.insert(support_set[0]);
        }
    }
    supports_map.len() - necessary.len()
}

fn count_fallen(
    start: usize,
    supports_map: &[Vec<usize>],
    supported_by_map: &[Vec<usize>],
) -> usize {
    let mut fallen = HashSet::from([start]);
    let mut to_process = supports_map[start].clone();

    while let Some(current) = to_process.pop() {
        if supported_by_map[current].iter().all(|b| fallen.contains(b)) {
            fallen.insert(current);

            for b in &supports_map[current] {
                if !fallen.contains(b) {
                    to_process.push(*b);
                }
            }
        }
    }

    fallen.len() - 1
}

fn part2(supports_map: &[Vec<usize>], supported_by_map: &[Vec<usize>]) -> usize {
    (0..supports_map.len())
        .map(|i| count_fallen(i, supports_map, supported_by_map))
        .sum()
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_lines::<String>(&filename);
    let mut bricks: Vec<_> = input.iter().map(|s| parse_brick(s)).collect();

    bricks.sort_by_key(|b| b.z1);
    make_fall(&mut bricks);

    let mut supports_map: Vec<Vec<usize>> = vec![];
    for b1 in bricks.iter() {
        supports_map.push(
            bricks
                .iter()
                .enumerate()
                .filter(|(_, b2)| supports(b1, b2))
                .map(|(i, _)| i)
                .collect(),
        );
    }
    let mut supported_by_map: Vec<Vec<usize>> = vec![];
    for b1 in bricks.iter() {
        supported_by_map.push(
            bricks
                .iter()
                .enumerate()
                .filter(|(_, b2)| supports(b2, b1))
                .map(|(i, _)| i)
                .collect(),
        );
    }

    println!("Part 1: {}", part1(&supports_map, &supported_by_map));
    println!("Part 2: {}", part2(&supports_map, &supported_by_map));
}
