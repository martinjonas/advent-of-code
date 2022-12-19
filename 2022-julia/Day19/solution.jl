int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

const re = r"Each ([a-z]+) robot costs ([^\.]+)\."

function parse_ingredient(i)
    n, r = split(i)
    string(r), int(n)
end

const r_to_i = Dict("ore" => 1, "clay" => 2, "obsidian" => 3, "geode" => 4)

function do_get_max(bp, cache, time, robots::Vector{Int}, ingredients::Vector{Int}, maxused::Vector{Int})
    if time <= 0
        return ingredients[4]
    end

    for i in 1:3
        ingredients[i] = clamp(ingredients[i], 0, (time - 1) * maxused[i])
    end

    key = (time, robots, ingredients)
    if haskey(cache, key)
        return cache[key]
    end

    m = do_get_max(bp, cache, time - 1, robots, ingredients + robots, maxused)

    if time > 1
        for (r, costs) in bp
            if r <= 3 && robots[r] >= maxused[r]
                continue
            end

            if all(map(<=, costs, ingredients))
                newrobots = copy(robots)
                newrobots[r] += 1
                m = max(m,
                        do_get_max(bp, cache, time - 1, newrobots, ingredients + robots - costs, maxused))
            end
        end
    end

    cache[key] = m
    return m
end

function get_max(bp::Dict{Int, Vector{Int}}, time)
    maxused = [0, 0, 0, 0]
    for (_, costs) in bp
        maxused = map(max, maxused, costs)
    end

    cache::Dict{Tuple{Int, Vector{Int}, Vector{Int}}, Int} = Dict()
    do_get_max(bp, cache, time, [1, 0, 0, 0], [0,0,0,0], maxused)
end

function get_blueprints(input)
    bps::Vector{Dict{Int, Vector{Int}}} = []

    for g in input
        d::Dict{Int, Vector{Int}} = Dict()
        for m in eachmatch(re, g)
            robot = r_to_i[m[1]]
            ingredients = map(parse_ingredient, split(m[2], " and "))
            costs = [0,0,0,0]
            for (r, num) in ingredients
                costs[r_to_i[r]] += num
            end
            d[robot] = costs
        end

        push!(bps, d)
    end

    bps
end

function part1(blueprints)
    get_max.(blueprints, 24) |> enumerate .|> prod |> sum
end

function part2(blueprints)
    get_max.(blueprints[1:3], 32) |> prod
end

blueprints = get_blueprints(input)
@time blueprints |> part1 |> println
@time blueprints |> part2 |> println
