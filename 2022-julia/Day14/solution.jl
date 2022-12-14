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

    start = (500, 0)
    sand = Set([start])
    to_process = [start]

    while !isempty(to_process)
        x, y = pop!(to_process)

        if y == maxy + 1
            continue
        end

        for i ∈ -1:1
            next = (x + i, y + 1)
            if next ∉ grid && next ∉ sand
                push!(sand, next)
                push!(to_process, next)
            end
        end
    end

    length(sand)
end

grid = build_grid(input)

grid |> part1 |> println
grid |> part2 |> println
