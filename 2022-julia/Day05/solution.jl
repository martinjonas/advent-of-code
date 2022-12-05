int(x) = parse(Int, x)

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = split(chomp(read(filename, String)), "\n\n")

struct Move
    num::Int
    from::Int
    to::Int
end

function parse_state(state)
    lines = split(state, "\n")

    num_columns = length(split(last(lines)))
    state = [[] for _ ∈ 1:num_columns]

    for line ∈ Iterators.reverse(@view lines[1:end-1])
        for col ∈ 1:num_columns
            index = 2 + 4*(col-1)
            if index <= length(line) && line[index] != ' '
                push!(state[col], line[index])
            end
        end
    end

    state
end

function parse_instructions(instructions)
    r = r"move (\d+) from (\d+) to (\d+)"
    lines = split(instructions, "\n")
    [Move(map(int, match(r, line).captures)...) for line in lines]
end

function part1(input)
    state = parse_state(input[1])
    instructions = parse_instructions(input[2])

    for move ∈ instructions
        for _ in 1:move.num
            push!(state[move.to], pop!(state[move.from]))
        end
    end

    join(map(last, state))
end

function part2(input)
    state = parse_state(input[1])
    instructions = parse_instructions(input[2])

    for move ∈ instructions
        to_move = last(state[move.from], move.num)

        for _ ∈ 1:move.num
            pop!(state[move.from])
        end

        append!(state[move.to], to_move)
    end

    join(map(last, state))
end

input |> part1 |> println
input |> part2 |> println
