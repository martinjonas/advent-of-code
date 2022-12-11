int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = read(filename, String)

struct Monkey
    items::Vector{Int}
    operation::Function
    test::Int
    ifTrue::Int
    ifFalse::Int
end

function get_monkeys(input)::Vector{Monkey}
    map(split(input, "\n\n")) do group
        starting = map(int, split(only(match(r"Starting items: (.+)", group)), ", "))
        operation = @eval $(Meta.parse("old -> " * only(match(r"Operation: new = (.+)", group))))
        test = int(only(match(r"Test: divisible by (\d+)", group)))
        ifTrue = int(only(match(r"If true: throw to monkey (\d+)", group)))
        ifFalse = int(only(match(r"If false: throw to monkey (\d+)", group)))

        Monkey(starting, operation, test, ifTrue, ifFalse)
    end
end

function solve(monkeys::Vector{Monkey}, rounds, worryLevelReduction)
    inspected::Vector{Int} = zeros(length(monkeys))

    for _ in 1:rounds, (currentIndex, current) in enumerate(monkeys)
        while !isempty(current.items)
            inspected[currentIndex] += 1
            toInspect = popfirst!(current.items)
            worryLevel = toInspect |> current.operation |> worryLevelReduction
            target = worryLevel % current.test == 0 ? current.ifTrue : current.ifFalse
            push!(monkeys[target+1].items, worryLevel)
        end
    end

    partialsort(inspected, 1:2, rev=true) |> prod
end

part1(monkeys::Vector{Monkey}) = solve(monkeys, 20, wl -> wl ÷ 3)

function part2(monkeys::Vector{Monkey})
    n = lcm((monkey.test for monkey in monkeys)...)
    solve(monkeys, 10_000, wl -> mod(wl, n))
end

monkeys = get_monkeys(input)
monkeys |> deepcopy |> part1 |> println
monkeys |> part2 |> println
