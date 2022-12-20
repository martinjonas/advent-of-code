int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = int.(split(read(filename, String), "\n"))

function solve(input::Vector{Int}, iterations)
    n = length(input)
    m(x) = mod1(x, n)

    next::Vector{Int} = [m(i+1) for i in 1:n]
    prev::Vector{Int} = [m(i-1) for i in 1:n]

    for _ in 1:iterations
        for i in 1:n
            move = mod(input[i], n - 1)
            move == 0 && continue

            new = i
            for _ in 1:move
                new = next[new]
            end

            next[prev[i]] = next[i]
            prev[next[i]] = prev[i]
            prev[next[new]] = i
            next[i] = next[new]
            prev[i] = new
            next[new] = i
        end
    end

    final::Vector{Int} = []
    cur = findfirst(x -> x == 0, input)
    for _ in 1:n
        push!(final, input[cur])
        cur = next[cur]
    end

    final[m(1001)] + final[m(2001)] + final[m(3001)]
end

@time solve(input, 1) |> println
@time solve(input .* 811589153, 10) |> println
