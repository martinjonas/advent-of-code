int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
parse_line(l) = int.(split(l, ","))
const input = parse_line.(readlines(filename))

const directions = [[0, 0, 1], [0, 0, -1], [0, 1, 0], [0, -1, 0], [1, 0, 0], [-1, 0, 0]]

function count_touching(cube, target)
    neighbors = [cube + Δ for Δ in directions]
    sum(neighbor ∈ target for neighbor in neighbors)
end


function part1(cubes)
    cubeset = Set(cubes)
    sum(c -> 6 - count_touching(c, cubeset), cubes)
end


function part2(cubes)
    cubeset = Set(cubes)

    minpos = reduce((c1, c2) -> min.(c1, c2), cubes) .- 1
    maxpos = reduce((c1, c2) -> max.(c1, c2), cubes) .+ 1

    start = minpos
    q = [start]
    seen = Set(q)

    while !isempty(q)
        current = popfirst!(q)

        for Δ in directions
            next = current + Δ

            if next in cubeset || next in seen || any(next .< minpos) || any(next .> maxpos)
                continue
            end

            push!(seen, next)
            push!(q, next)
        end
    end

    sum(c -> count_touching(c, seen), cubes)
end


@time input |> part1 |> println
@time input |> part2 |> println
