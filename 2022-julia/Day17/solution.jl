const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = read(filename, String)

const rocks = [
    Set([[1,1], [2,1], [3,1], [4,1]]),         # ["####"],
    Set([[2,1], [1,2], [2,2], [3,2], [2,3]]),  # [".#.", "###", ".#."],
    Set([[1,1], [2,1], [3,1], [3,2], [3,3]]),  # ["..#", "..#", "###"],
    Set([[1,1], [1,2], [1,3], [1,4]]),         # ["#", "#", "#", "#"],
    Set([[1,1], [2,1], [1,2], [2,2]])]         # ["##", "##"]]

function is_coliding(rock, offset, fallen)
    moved = Set(r + offset for r in rock)
    !isdisjoint(moved, fallen)
end

function place!(rock, offset, fallen)
    moved = Set(r + offset for r in rock)
    @assert isdisjoint(moved, fallen)
    union!(fallen, moved)
end

function get_topmost(fallen, height)
    maxy = maximum(y for (_, y) in fallen)
    Set((x, y - (maxy - height)) for (x, y) in fallen if y >= maxy - height)
end

const w = 7

function solve(input, target)
    fallen = Set([x, 0] for x in 1:w)

    cur_jet = 1
    cur_rock = 1

    yoffset = 3

    fingerprints = Dict()
    accelerated_offset = 0
    longest_fall = 0

    i = 0
    while i <= target
        i += 1

        xoffset = 2
        rock = rocks[cur_rock]
        rmin, rmax = extrema(x for (x, _) in rock)

        falling_for = 0
        while true
            falling_for += 1
            @assert !is_coliding(rock, [xoffset, yoffset], fallen)

            dx = input[cur_jet] == '<' ? -1 : 1
            cur_jet = mod1(cur_jet + 1, length(input))

            if !is_coliding(rock, [xoffset + dx, yoffset], fallen) && 1 <= rmin + xoffset + dx && rmax + xoffset + dx <= w
                xoffset += dx
            end

            if !is_coliding(rock, [xoffset, yoffset - 1], fallen)
                yoffset -= 1
            else
                place!(rock, [xoffset, yoffset], fallen)
                yoffset = maximum(y for (_, y) in fallen) + 3
                break
            end
        end
        if falling_for > longest_fall
            longest_fall = falling_for
            fingerprints = Dict()
        end

        fingerprint = (cur_rock, cur_jet, get_topmost(fallen, longest_fall))
        if haskey(fingerprints, fingerprint)
            previ, prevoffset = fingerprints[fingerprint]
            idiff = i - previ
            ydiff = yoffset - prevoffset
            println("Rock acceleration kicked in! Found cycle of length $idiff, which increases height by $ydiff.")

            remaining = target - i
            cycles = remaining ÷ idiff
            target -= idiff * cycles
            accelerated_offset = ydiff * cycles - 1

            fingerprints = Dict()
        end

        fingerprints[fingerprint] = (i, yoffset)
        cur_rock = mod1(cur_rock + 1, length(rocks))
    end

    yoffset - 3 + accelerated_offset
end

solve(input, 2022) |> println
solve(input, 1000000000000) |> println
