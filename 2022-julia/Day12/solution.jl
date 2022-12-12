int(x) = parse(Int, x)
ci(x) = CartesianIndex(x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]

function find_shortest(grid, starts, target)
    queue = starts
    distances = Dict(start => 0 for start in starts)

    while !isempty(queue)
        current = popfirst!(queue)
        dist = distances[current]

        current == target && return dist

        for Δ in ((0, 1), (0, -1), (1, 0), (-1, 0))
            neigh = current + ci(Δ)

            checkbounds(Bool, grid, neigh) || continue
            !(haskey(distances, neigh)) || continue
            grid[neigh] <= grid[current] + 1 || continue

            push!(queue, neigh)
            distances[neigh] = dist + 1
        end
    end
end

const grid = hcat(collect.(readlines(filename))...)

const S = findfirst(x -> x == 'S', grid)
const E = findfirst(x -> x == 'E', grid)

grid[S] = 'a'
grid[E] = 'z'

println("Part 1: ", find_shortest(grid, [S], E))
println("Part 2: ", find_shortest(grid, findall(x -> x == 'a', grid), E))
