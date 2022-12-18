int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
parse_line(l) = int.(split(l, ","))
const input = parse_line.(readlines(filename))


function count_touching(cube, target)
    sum(sum(abs.(cube2-cube)) == 1 for cube2 in target)
end


part1(cubes) = sum(c -> 6 - count_touching(c, cubes), cubes)


function part2(cubes)
    cubeset = Set(cubes)

    minpos = reduce((c1, c2) -> min.(c1, c2), cubes) .- 1
    maxpos = reduce((c1, c2) -> max.(c1, c2), cubes) .+ 1

    start = minpos
    q = [start]
    seen = Set(q)

    directions = [[0, 0, 1], [0, 0, -1], [0, 1, 0], [0, -1, 0], [1, 0, 0], [-1, 0, 0]]

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


input |> part1 |> println
input |> part2 |> println
