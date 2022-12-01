function solve(lines::Vector{String})
    sums = [0]
    for line in lines
        if line == ""
            push!(sums, 0)
        else
            sums[end] += parse(Int, line)
        end
    end

    println(maximum(sums))
    println(sum(sort(sums, rev=true)[1:3]))
end

filename = (length(ARGS) == 0) ? "input" : ARGS[1]
lines = readlines(filename)
@time solve(lines)
