int(x) = parse(Int, x)

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)
const parsed = map(input) do line map(int, split(line, r"-|,")) end

contained(l1, r1, l2, r2) = (l1 <= l2 <= r2 <= r1) || (l2 <= l1 <= r1 <= r2)
overlap(l1, r1, l2, r2) = (l1 <= l2 <= r1) || (l2 <= l1 <= r2)

parsed .|> (x -> contained(x...)) |> sum |> println
parsed .|> (x -> overlap(x...)) |> sum |> println
