int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const re = r"Valve (.+) has flow rate=(\d+); tunnels? leads? to valves? (.+)"

const input = readlines(filename)

valve_indices = Dict("AA" => 1)

function valve_to_int(s)
    if haskey(valve_indices, s)
        return valve_indices[s]
    else
        valve_indices[s] = length(valve_indices) + 1
    end
end

function do_solve(remaining::BitSet,
                  l::Int, t::Int, elephants::Int,
                  rates::Dict, neighbors::Dict, total_time::Int,
                  cache)
    length(remaining) == 0 && return 0

    key = (BitSet(remaining), l, t, elephants)
    haskey(cache, key) && return cache[key]

    best = 0

    for (n, d) ∈ neighbors[l]
        if t - d - 1 > 1 && n ∈ remaining
            delete!(remaining, n)
            best = max(best,
                      rates[n] * (t - d - 1) +
                          do_solve(remaining, n, t - d - 1, elephants, rates, neighbors, total_time, cache))
            push!(remaining, n)
        end
    end

    if elephants > 0
        best = max(best, do_solve(remaining, 1, total_time, elephants - 1, rates, neighbors, total_time, cache))
    end

    cache[key] = best
    best
end

function get_distances(from, neighbors, rates)
    queue = [(0, from)]
    seen = Set([from])

    distances = []

    while !isempty(queue)
        dist, cur = popfirst!(queue)

        if rates[cur] != 0
            push!(distances, (cur, dist))
        end

        for n ∈ neighbors[cur]
            n ∈ seen && continue
            push!(queue, (dist+1, n))
            push!(seen, n)
        end
    end

    distances
end

function solve(input, time, elephants)
    rates::Dict{Int, Int} = Dict()
    neighbors::Dict{Int, Array{Int}} = Dict()
    for line in input
        from, rate, to = match(re, line).captures
        valve_num = valve_to_int(from)
        rates[valve_num] = int(rate)
        neighbors[valve_num] = valve_to_int.(split(to, ", "))
    end

    nonzero = [valve for (valve, rate) in rates if rate > 0]

    distances::Dict{Int, Array{Tuple{Int, Int}}} = Dict()
    distances[1] = get_distances(1, neighbors, rates)
    for v1 in nonzero
        distances[v1] = get_distances(v1, neighbors, rates)
    end

    cache::Dict{Tuple{BitSet, Int, Int, Int}, Int} = Dict()
    @time do_solve(BitSet(nonzero), 1, time, elephants, rates, distances, time, cache)
end

solve(input, 30, 0) |> println
solve(input, 26, 1) |> println
