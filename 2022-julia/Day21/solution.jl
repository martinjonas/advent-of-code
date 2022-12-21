int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

const opmap = Dict("+" => (+), "-" => (-), "*" => (*), "/" => (÷))

const Var = String

struct Sexpr
    op::String
    l::Union{Int, Sexpr, Var}
    r::Union{Int, Sexpr, Var}
end

function symeval(node, definitions, into_var)
    if node == into_var
        return node
    end

    expr = definitions[node]

    if typeof(expr) == Int
        return expr
    end

    lres = symeval(expr.l, definitions, into_var)
    rres = symeval(expr.r, definitions, into_var)
    if typeof(lres) == Int && typeof(rres) == Int
        return opmap[expr.op](lres, rres)
    end

    return Sexpr(expr.op, lres, rres)
end

function parse_input(input)
    definitions::Dict{String, Union{Int, Sexpr}} = Dict()

    for line in input
        result, expr = split(line, ": ")
        args = split(expr, " ")

        if length(args) == 1
            definitions[result] = int(only(args))
        else
            l, op, r = string.(args)
            definitions[result] = Sexpr(op, l, r)
        end
    end

    definitions
end


function part1(definitions)
    symeval("root", definitions, nothing)
end


function make_equal(_::String, num::Int)
    return num
end

function make_equal(expr::Sexpr, num::Int)
    if expr.op == "+"
        if typeof(expr.l) == Int
            # l + r == num   --->   r == num - l
            return make_equal(expr.r, num - expr.l)
        else
            # l + r == num   --->   l == num - r
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


function part2(definitions)
    equality = definitions["root"]
    res1 = symeval(equality.l, definitions, "humn")
    res2 = symeval(equality.r, definitions, "humn")

    if typeof(res1) == Int
        make_equal(res2, res1)
    else
        make_equal(res1, res2)
    end
end


const definitions = parse_input(input)
@time definitions |> part1 |> println
@time definitions |> part2 |> println
