use std::fs::read_to_string;
use std::env;
use std::collections::HashMap;

fn hash(input: &str) -> u32 {
    let mut current = 0;
    for ch in input.chars() {
        current += ch as u32;
        current *= 17;
        current %= 256;
    }
    current
}

fn part1(input: &str) -> u32 {
    input.trim().split(',').map(hash).sum()
}

#[derive(Clone,Debug)]
struct LensBox {
    lenses: HashMap<String, (u32,u32)>,
    next_id: u32
}

impl LensBox {
    fn new() -> Self {
        LensBox{ lenses: HashMap::new(), next_id: 0 }
    }

    fn add(&mut self, label: String, lens: u32) {
        self.lenses.entry(label).and_modify(|l| l.1 = lens).or_insert((self.next_id, lens));
        self.next_id += 1;
    }

    fn remove(&mut self, label: &String) {
        self.lenses.remove(label);
    }

    fn power(&self) -> u32 {
        let mut lenses: Vec<_> = self.lenses.values().collect();
        lenses.sort();
        lenses.iter().zip(1..).map(|(l,i)| l.1 * i).sum()
    }
}

fn part2(input: &str) -> u32 {
    let mut boxes: Vec<LensBox> = vec![LensBox::new(); 256];

    for instr in input.trim().split(',') {
        let mut parts = instr.split(|c| c == '=' || c == '-');
        let label = parts.next().unwrap().to_string();
        let lens = parts.next().unwrap().parse::<u32>().ok();

        let hash = hash(&label) as usize;
        match lens {
            None => boxes[hash].remove(&label),
            Some(value) => boxes[hash].add(label, value)
        }
    }

    boxes.iter().zip(1..).map(|(b,i)| i * b.power()).sum()
}

fn main() {
    let filename = env::args().nth(1).unwrap_or("input".to_string());
    let input = read_to_string(filename).unwrap();

    println!("Part 1: {}", part1(&input));
    println!("Part 2: {}", part2(&input));
}
