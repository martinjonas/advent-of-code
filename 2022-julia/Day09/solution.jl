int(x) = parse(Int, x)

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = split.(readlines(filename))

function moved_tail(h, t)
    distances = h - t
    if maximum(abs.(distances)) <= 1
        return t
    end

    t + sign.(distances)
end

function solve(input, ropelen)
    rope = [[0,0] for _ in 1:ropelen]
    move_to_dir = Dict("R" => [1, 0], "L" => [-1, 0],
                       "U" => [0, 1], "D" => [0, -1])

    tail_positions = Set()
    push!(tail_positions, rope[ropelen])
    for (move, num) in input
        for _ in 1:int(num)
            rope[1] = rope[1] + move_to_dir[move]

            for i in 2:ropelen
                rope[i] = moved_tail(rope[i-1], rope[i])
            end

            push!(tail_positions, rope[ropelen])
        end
    end

    length(tail_positions)
end

solve(input, 2) |> println
solve(input, 10) |> println
