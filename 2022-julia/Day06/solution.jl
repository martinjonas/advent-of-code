filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

function marker(line, num)
    for i in num:length(line)
        if length(Set(line[i-num+1:i])) == num
            return i
        end
    end
end

part1(input) = sum(line -> marker(line, 4), input)
part2(input) = sum(line -> marker(line, 14), input)

input |> part1 |> println
input |> part2 |> println
