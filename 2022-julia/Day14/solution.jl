using Base.Iterators

int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

range_any(from, to) = from == to ? Iterators.repeated(from) : from:sign(to-from):to

function build_grid(input)
    grid = Set()

    for line in input
        previous = nothing
        for point in split(line, " -> ")
            x, y = int.(split(point, ","))

            if !isnothing(previous)
                prevx, prevy = previous

                for point ∈ zip(range_any(prevx, x), range_any(prevy, y))
                    push!(grid, point)
                end
            end

            previous = (x, y)
        end
    end

    grid
end

function part1(grid)
    maxy = maximum(y for (_, y) in grid)

    sand = Set()

    pos = (500, 0)
    while pos[2] <= maxy
        x, y = pos
        next = first(p for p in ((x,y+1), (x-1,y+1), (x+1,y+1), (x, y))
                         if p ∉ grid && p ∉ sand)

        if next != pos
            pos = next
            continue
        end

        push!(sand, pos)

        pos = (500, 0)
    end

    length(sand)
end

function part2(grid)
    maxy = maximum(y for (_, y) in grid)

    sand = Set()

    pos = (500, 0)
    while true
        x, y = pos
        next = first(p for p in ((x,y+1), (x-1,y+1), (x+1,y+1), (x, y))
                         if p ∉ grid && p ∉ sand && (p[2] < maxy+2))

        if next != pos
            pos = next
            continue
        end

        push!(sand, pos)

        if pos == (500, 0)
            return length(sand)
        end

        pos = (500, 0)
    end
end

grid = build_grid(input)

grid |> part1 |> println
grid |> part2 |> println
