int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

const opmap = Dict(
    "+" => (a,b) -> a+b,
    "-" => (a,b) -> a-b,
    "*" => (a,b) -> a*b,
    "/" => (a,b) -> a÷b
)

struct Sexpr
    op::String
    l::Union{Int, Sexpr, String}
    r::Union{Int, Sexpr, String}
end


function symeval(node, operations, into_var)
    if node == into_var
        return node
    end

    expr = operations[node]

    if typeof(expr) == Int
        return expr
    end

    l, op, r = expr
    lres = symeval(l, operations, into_var)
    rres = symeval(r, operations, into_var)
    if typeof(lres) == Int && typeof(rres) == Int
        return opmap[op](lres, rres)
    end

    return Sexpr(op, lres, rres)
end


function part1(input)
    operations = Dict()

    for line in input
        result, expr = split(line, ": ")
        args = split(expr, " ")

        if length(args) == 1
            operations[result] = int(only(args))
        else
            operations[result] = args
        end
    end

    symeval("root", operations, nothing)
end


function make_equal(expr, num::Int)
    if expr == "humn"
        return num
    end

    @assert typeof(expr) == Sexpr
    if expr.op == "+"
        if typeof(expr.l) == Int
            return make_equal(expr.r, num - expr.l)
        else
            return make_equal(expr.l, num - expr.r)
        end
    elseif expr.op == "*"
        if typeof(expr.l) == Int
            # l * r == num   --->   r == num / l
            return make_equal(expr.r, num ÷ expr.l)
        else
            # l * r == num   --->   l == num / r
            return make_equal(expr.l, num ÷ expr.r)
        end
    elseif expr.op == "-"
        if typeof(expr.l) == Int
            # l - r == num   --->   r == l - num
            return make_equal(expr.r, expr.l - num)
        else
            # l - r == num   --->   l == num - r
            return make_equal(expr.l, num + expr.r)
        end
    elseif expr.op == "/"
        if typeof(expr.l) == Int
            # l / r == num   --->   r == l / num
            return make_equal(expr.r, expr.l ÷ num)
        else
            # l / r == num   --->   l == num * r
            return make_equal(expr.l, num * expr.r)
        end
    end
end

function part2(input)
    operations = Dict()

    for line in input
        result, expr = split(line, ": ")
        args = split(expr, " ")

        if length(args) == 1
            operations[result] = int(only(args))
        else
            operations[result] = map(string, args)
        end
    end

    arg1, _, arg2 = operations["root"]
    res1 = symeval(arg1, operations, "humn")
    res2 = symeval(arg2, operations, "humn")

    if typeof(res1) == Int
        make_equal(res2, res1)
    else
        make_equal(res1, res2)
    end
end

@time input |> part1 |> println
@time input |> part2 |> println
