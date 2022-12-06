filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = read(filename, String)

function marker(line, num)
    for i in num:length(line)
        if length(Set(line[i-num+1:i])) == num
            return i
        end
    end
end

marker(input, 4) |> println
marker(input, 14) |> println
