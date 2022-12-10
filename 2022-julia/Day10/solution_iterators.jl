int(x) = parse(Int, x)

input = Iterators.map(split, eachline("input"))
expanded = Iterators.map(line -> length(line) == 1 ? (0) : (0, int(line[2])), input)
differences = Iterators.flatten(expanded)
with_first = Iterators.flatten(((1), differences))
values = Iterators.accumulate(+, with_first)
trimmed = Iterators.take(values, 240)
indexed = Iterators.enumerate(trimmed)

function print_pixel((time, value))
    current_pixel = (time - 1) % 40
    print(abs(current_pixel - value) <= 1 ? '█' : ' ')

    if current_pixel == 39
        println()
    end

    time % 40 == 20 ? time * value : 0
end

println("Part 1:", sum(print_pixel, indexed))
