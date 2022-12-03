using Base.Iterators

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
input = readlines(filename)

function score(ch)
    if islowercase(ch)
        return ch - 'a' + 1
    else
        return ch - 'A' + 27
    end
end

function part1(input)
    result = 0
    for line in input
        mid = length(line) ÷ 2
        result += sum(score, Set(line[1:mid]) ∩ Set(line[mid+1:end]))
    end
    result
end

function part2(input)
    groups = partition(input, 3)
    sum(group -> sum(score, mapreduce(Set, ∩, group)), groups)
end

@time input |> part1 |> println
@time input |> part2 |> println
