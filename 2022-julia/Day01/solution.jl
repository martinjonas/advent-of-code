int(x) = parse(Int, x)

function solve(input::String)
    groups = split(input, "\n\n") .|> split
    sums = sum.(int, groups)

    println(maximum(sums))
    println(sum(partialsort(sums, 1:3, rev=true)))
end

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
input = read(filename, String)
@time solve(input)
