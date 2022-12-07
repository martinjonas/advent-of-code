results = [
    3 0 6;
    6 3 0;
    0 6 3
]

parse_his(x::AbstractString) = x[1] - 'A' + 1
parse_my(x::AbstractString) = x[1] - 'X' + 1

function part1(input)
    score = 0
    for (his, my) in input
        his = parse_his(his)
        my = parse_my(my)
        score += my + results[my, his]
    end
    println(score)
end

parse_result(x::AbstractString) = 3(x[1] - 'X')

function part2(input)
    score = 0
    for (his, res) in input
        his = parse_his(his)
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
