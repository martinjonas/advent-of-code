int(x) = parse(Int, x)
ci(x) = CartesianIndex(x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = hcat(collect.(readlines(filename))...)

function height(ch)
    if ch == 'S'
        return 'a'
    elseif ch == 'E'
        return 'z'
    end

    return ch
end

function bfs(grid, starts)
    to_process = [(start, 0) for start in starts]
    seen = Set(starts)

    while !isempty(to_process)
        current, dist = popfirst!(to_process)

        if grid[current] == 'E'
            return dist
        end

        for Δ in ((0, 1), (0, -1), (1, 0), (-1, 0))
            neigh = current + ci(Δ)

            checkbounds(Bool, grid, neigh) || continue
            !(neigh ∈ seen) || continue
            height(grid[neigh]) <= height(grid[current]) + 1 || continue

            push!(to_process, (neigh, dist+1))
            push!(seen, neigh)
        end
    end

    -1
end

part1(grid) = bfs(grid, [findfirst(x -> x == 'S', grid)])
part2(grid) = bfs(grid, findall(x -> x ∈ "Sa", grid))

input |> part1 |> println
input |> part2 |> println
