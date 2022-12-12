int(x) = parse(Int, x)
ci(x) = CartesianIndex(x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]

function find_shortest(grid, starts, target)
    to_process = [(start, 0) for start in starts]
    seen = Set(starts)

    while !isempty(to_process)
        current, dist = popfirst!(to_process)

        current == target && return dist

        for Δ in ((0, 1), (0, -1), (1, 0), (-1, 0))
            neigh = current + ci(Δ)

            checkbounds(Bool, grid, neigh) || continue
            !(neigh ∈ seen) || continue
            grid[neigh] <= grid[current] + 1 || continue

            push!(to_process, (neigh, dist+1))
            push!(seen, neigh)
        end
    end

    -1
end

const grid = hcat(collect.(readlines(filename))...)

const S = findfirst(x -> x == 'S', grid)
const E = findfirst(x -> x == 'E', grid)

grid[S] = 'a'
grid[E] = 'z'

part1(grid) = find_shortest(grid, [S], E)
part2(grid) = find_shortest(grid, findall(x -> x == 'a', grid), E)

grid |> part1 |> println
grid |> part2 |> println
