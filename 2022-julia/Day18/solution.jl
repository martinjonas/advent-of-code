int(x) = parse(Int, x)
ci(x) = CartesianIndex(x...)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
parse_line(l) = ci(int.(split(l, ",")))
const input = parse_line.(readlines(filename))

const directions = map(ci, [(0, 0, 1), (0, 0, -1), (0, 1, 0), (0, -1, 0), (1, 0, 0), (-1, 0, 0)])

count_touching(cube, target) = length(target ∩ (Ref(cube) .+ directions))

function part1(cubes)
    cubeset = Set(cubes)
    sum(c -> 6 - count_touching(c, cubeset), cubes)
end

function part2(cubes)
    cubeset = Set(cubes)

    minpos, maxpos = extrema(cubes) .+ (CartesianIndex(-1, -1, -1), CartesianIndex(1, 1, 1))

    start = minpos
    q = [start]
    seen = Set(q)

    while !isempty(q)
        current = popfirst!(q)

        for Δ in directions
            next = current + Δ
            if next in cubeset || next in seen || next ∉ minpos:maxpos
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
