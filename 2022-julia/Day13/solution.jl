int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = read(filename, String)

function compare_pair(l::Int, r::Int)
    if l == r
        return nothing
    else
        return l < r
    end
end

function compare_pair(l::Vector, r::Vector)
    for (x, y) in zip(l, r)
        cmp = compare_pair(x, y)
        if !isnothing(cmp)
            return cmp
        end
    end

    if length(l) == length(r)
        return nothing
    end

    length(l) <= length(r)
end

function compare_pair(l::Int, r::Vector)
    compare_pair([l], r)
end

function compare_pair(l::Vector, r::Int)
    compare_pair(l, [r])
end

function part1(input)
    groups = split(input, "\n\n")

    result = 0
    for (i, group) in enumerate(groups)
        l, r = eval.(Meta.parse.(split(group, "\n")))

        cmp = compare_pair(l, r)
        if cmp === true
            result += i
        end
    end

    result
end

function part2(input)
    d1, d2 = [[2]], [[6]]
    packets = eval.(Meta.parse.(split(input)))
    push!(packets, d1, d2)

    sort!(packets, lt=compare_pair)
    findfirst(x -> x == d1, packets) * findfirst(x -> x == d2, packets)
end

input |> part1 |> println
input |> part2 |> println
