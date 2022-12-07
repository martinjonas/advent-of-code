filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

function getsize(files, dirs, current, dirsizes)
    filesize = sum(get(files, current, []); init=0)
    dirsize = sum(getsize(files, dirs, vcat(current, d), dirsizes)
                  for d in get(dirs, current, []); init=0)
    total = filesize + dirsize

    dirsizes[current] = total
    return total
end

function dirsizes(files, dirs)
    dirsizes = Dict()
    getsize(files, dirs, [], dirsizes)
    return dirsizes
end

function solve(input)
    files = Dict()
    dirs = Dict()

    current = []
    for line in input
        parts = split(line)
        if parts[1] == "\$" && parts[2] == "cd"
            if parts[3] == ".."
                pop!(current)
            elseif parts[3] == "/"
                current = []
            else
                push!(current, parts[3])
            end
        elseif parts[1] == "\$" && parts[2] == "ls"
            continue
        elseif parts[1] == "dir"
            push!(get!(dirs, copy(current), []), parts[2])
        else
            size = parse(Int, parts[1])
            push!(get!(files, copy(current), []), size)
        end
    end

    size_map = dirsizes(files, dirs)
    sizes = collect(values(size_map))

    println("Part 1: ", sum(filter(s -> s <= 100000, sizes)))

    total = size_map[[]]
    unused = 70000000 - total
    tofree = 30000000 - unused

    println("Part 2: ", minimum(filter(s -> s >= tofree, sizes)))
end

solve(input)
