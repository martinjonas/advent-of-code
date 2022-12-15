int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]

function parse_line(line)
    map(int, match(r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)", line))
end

const input = parse_line.(readlines(filename))

d(x, y, x_, y_) = abs(x - x_) + abs(y - y_)

function part1(input)
    sensordists::Array{Tuple{Int64, Int64, Int64}} = []
    beacons = Set()
    for (sx, sy, bx, by) in input
        push!(sensordists, (sx, sy, d(sx, sy, bx, by)))
        push!(beacons, (bx, by))
    end

    minx = minimum(x for (x, _, _) in sensordists)
    maxx = maximum(x for (x, _, _) in sensordists)
    maxdist = maximum(dist for (_, _, dist) in sensordists)

    sensors = Set((x, y) for (x, y, _) in sensordists)

    y = 2000000

    result = 0
    for x in minx-maxdist:maxx+maxdist
        covered = false
        for (sx, sy, dist) in sensordists
            if d(x, y, sx, sy) <= dist && (x, y) ∉ sensors && (x, y) ∉ beacons
                covered = true
            end
        end

        if covered
            result += 1
        end
    end

    result
end

function part2(input)
    # this little typing annotation reduces the runtime from 22 s to 0.30 s
    sensordists::Array{Tuple{Int64, Int64, Int64}} = []
    for (sx, sy, bx, by) in input
        dist = d(sx, sy, bx, by)
        push!(sensordists, (sx, sy, dist))
    end

    maxx = 4000000
    maxy = 4000000

    for y in 0:maxy
        x = 0

        while x <= maxx
            covered = false

            for (sx, sy, sensordist) in sensordists
                curdist = d(x, y, sx, sy)
                if curdist <= sensordist
                    fromborder = sensordist - curdist
                    if x < sx
                        fromsensor = sx - x
                        x += 2fromsensor + fromborder + 1
                    else
                        x += fromborder + 1
                    end
                    covered = true
                    break
                end
            end

            if !covered
                return 4000000x+y
            end
        end
    end
end


input |> part1 |> println
input |> part2 |> println
