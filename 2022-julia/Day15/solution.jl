int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const line_re = r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"
parse_line(line) = map(int, match(line_re, line))
const input = parse_line.(readlines(filename))

d(x, y, x_, y_) = abs(x - x_) + abs(y - y_)

function get_covering_sensor(input, x, y)
    for (sx, sy, bx, by) in input
        range = d(sx, sy, bx, by)
        if d(x, y, sx, sy) <= range
            return (sx, sy, range, x == bx && y == by)
        end
    end
end


function part1(input, y)
    minx, maxx = extrema(line[1] for line in input)
    maxdist = maximum(d(line...) for line in input)

    result = 0
    for x in minx-maxdist:maxx+maxdist
        covering_sensor = get_covering_sensor(input, x, y)
        if !isnothing(covering_sensor) && !covering_sensor[4]
            result += 1
        end
    end

    result
end


function part2(input)
    maxx, maxy = 4000000, 4000000

    for y in 0:maxy
        x = 0

        while x <= maxx
            covering_sensor = get_covering_sensor(input, x, y)
            if isnothing(covering_sensor)
                return 4000000x+y
            end

            sx, sy, range, _ = covering_sensor
            x = sx + (range - abs(sy - y)) + 1 # move beyond the sensor range
        end
    end
end


part1(input, 2000000) |> println
input |> part2 |> println
