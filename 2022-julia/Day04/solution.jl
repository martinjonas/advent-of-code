int(x) = parse(Int, x)
parse_line(line) = split(line, r"-|,") .|> int

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename) .|> parse_line

contained(l1, r1, l2, r2) = (l1 ≤ l2 ≤ r2 ≤ r1) || (l2 ≤ l1 ≤ r1 ≤ r2)
overlap(l1, r1, l2, r2) = (l1 ≤ l2 ≤ r1) || (l2 ≤ l1 ≤ r2)

input .|> (x -> contained(x...)) |> sum |> println
input .|> (x -> overlap(x...)) |> sum |> println
