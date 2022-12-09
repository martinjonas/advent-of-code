int(x) = parse(Int, x)

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = split.(readlines(filename))

struct Point
    x::Int
    y::Int
end

function moved_tail(h, t)
    dx = h.x - t.x
    dy = h.y - t.y
    if abs(dx) <= 1 && abs(dy) <= 1
        return t
    end

    Point(t.x + sign(dx), t.y + sign(dy))
end

function solve(input, ropelen)
    rope = [Point(0,0) for _ in 1:ropelen]

    tail_positions = Set()
    push!(tail_positions, rope[ropelen])
    for (dir, num) in input
        for _ in 1:int(num)
            dx, dy = 0, 0
            if dir == "R"
                dx = 1
            elseif dir == "L"
                dx = -1
            elseif dir == "U"
                dy = 1
            elseif dir == "D"
                dy = -1
            else
                @assert false
            end
            rope[1] = Point(rope[1].x + dx, rope[1].y + dy)

            for i in 2:ropelen
                rope[i] = moved_tail(rope[i-1], rope[i])
            end
            push!(tail_positions, rope[ropelen])
        end
    end

    length(tail_positions)
end

solve(input, 2) |> println
solve(input, 10) |> println
