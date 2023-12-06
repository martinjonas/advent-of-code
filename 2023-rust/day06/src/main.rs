fn dist_from_time(hold_time: usize, total_time: usize) -> usize {
    (total_time - hold_time) * hold_time
}

fn part1(times: Vec<usize>, distances: Vec<usize>) -> usize {
    times.iter().zip(distances.iter()).map(|(&time, &record)| (1..time).map(|hold| dist_from_time(hold, time)).filter(|&d| d > record).count() as usize).product::<usize>()
}

fn main() {
    println!("Part 1: {}", part1(vec![7, 15, 30], vec![7, 40, 200]));
    println!("Part 2: {}", part1(vec![71530], vec![740200]));
}
