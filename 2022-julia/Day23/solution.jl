int(x) = parse(Int, x)
ci(x, y) = CartesianIndex(x, y)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const grid = reduce(hcat, collect.(readlines(filename)))

const neighbors = [ci(x, y) for x ∈ -1:1 for y ∈ -1:1 if x != 0 || y != 0]

function step(elves, directions)
    proposed = Dict()
    proposedby = Dict()

    for elf in elves
        movesto = elf

        if !isdisjoint(elves, Ref(elf) .+ neighbors)
            for direction ∈ directions
                targets = Ref(elf) .+ direction

                if isdisjoint(elves, targets)
                    movesto = targets[2]
                    break
                end
            end
        end

        proposed[elf] = movesto
        get!(proposedby, movesto, 0)
        proposedby[movesto] += 1
    end

    Set(proposedby[new] == 1 ? new : old for (old, new) ∈ proposed)
end


function part1(elves)
    directions = [[ci(x, -1) for x ∈ -1:1], [ci(x, 1) for x ∈ -1:1],
                  [ci(-1, y) for y ∈ -1:1], [ci(1, y) for y ∈ -1:1]]

    for _ in 1:10
        elves = step(elves, directions)
        circshift!(directions, -1)
    end

    length(range(extrema(elves)...)) - length(elves)
end

function part2(elves)
    directions = [[ci(x, -1) for x ∈ -1:1], [ci(x, 1) for x ∈ -1:1],
                  [ci(-1, y) for y ∈ -1:1], [ci(1, y) for y ∈ -1:1]]

    i = 1
    while true
        newelves = step(elves, directions)
        circshift!(directions, -1)

        if elves == newelves
            return i
        end

        elves = newelves

        i += 1
    end
end

const elves = Set(i for i ∈ CartesianIndices(grid) if grid[i] == '#')
@time elves |> part1 |> println
@time elves |> part2 |> println
