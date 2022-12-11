int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = read(filename, String)

mutable struct Monkey
    items::Vector{Int}
    operation::Expr
    test::Int
    ifTrue::Int
    ifFalse::Int
end

function get_monkeys(input)::Vector{Monkey}
    groups = split(input, "\n\n")
    monkeys = []

    for group in groups
        starting = map(int, split(match(r"Starting items: (.+)", group).captures[1], ", "))
        operation = Meta.parse(match(r"Operation: new = (.+)", group).captures[1])
        test = int(match(r"Test: divisible by (\d+)", group).captures[1])
        ifTrue = int(match(r"If true: throw to monkey (\d+)", group).captures[1])
        ifFalse = int(match(r"If false: throw to monkey (\d+)", group).captures[1])

        push!(monkeys, Monkey(starting, operation, test, ifTrue, ifFalse))
    end

    monkeys
end

old = 0

function solve(monkeys::Vector{Monkey}, rounds, worryLevelReduction)
    inspected::Vector{Int} = zeros(length(monkeys))

    for _ in 1:rounds
        for (currentIndex, current) in enumerate(monkeys)
            while !isempty(current.items)
                inspected[currentIndex] += 1
                toInspect = popfirst!(current.items)
                global old = toInspect
                worryLevel = eval(current.operation)
                worryLevel = worryLevelReduction(worryLevel)

                target = worryLevel % current.test == 0 ? current.ifTrue : current.ifFalse
                push!(monkeys[target+1].items, worryLevel)
            end
        end
    end

    @show inspected
    partialsort!(inspected, 2, rev=true)
    prod(inspected[1:2])
end

function part1(monkeys::Vector{Monkey})
    solve(monkeys, 20, wl -> wl ÷ 3)
end

function part2(monkeys::Vector{Monkey})
    n = lcm((monkey.test for monkey in monkeys)...)
    solve(monkeys, 10_000, wl -> mod(wl, n))
end

monkeys = get_monkeys(input)
monkeys |> deepcopy |> part1 |> println
monkeys |> part2 |> println
