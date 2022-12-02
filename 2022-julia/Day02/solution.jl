results = [
    3 0 6;
    6 3 0;
    0 6 3
]

function parse_move(x)
    if x == "A" || x == "X"
        return 1
    elseif x == "B" || x == "Y"
        return 2
    else
        return 3
    end
end

function part1(input)
    score = 0
    for (his, my) in input
        his = parse_move(his)
        my = parse_move(my)
        score += my + results[my, his]
    end
    println(score)
end

function parse_result(x)
    if x == "X"
        return 0
    elseif x == "Y"
        return 3
    else
        return 6
    end
end

function part2(input)
    score = 0
    for (his, res) in input
        his = parse_move(his)
        res = parse_result(res)
        my = findfirst(x -> x == res, results[:, his])
        score += my + res
    end
    println(score)
end

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
input = split.(readlines(filename))
@time part1(input)
@time part2(input)
