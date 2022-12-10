int(x) = parse(Int, x)

const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = split.(readlines(filename))

function untime(input)
    instructions = []
    for instr in input
        if instr[1] == "noop"
            push!(instructions, instr)
        elseif instr[1] == "addx"
            push!(instructions, ["noop"])
            push!(instructions, instr)
        end
    end
    instructions
end

function run(callback, instructions)
    register = 1
    time = 1

    for instr in instructions
        callback((time, register))

        time += 1

        if instr[1] == "addx"
            register += int(instr[2])
        end
    end
end

function part1(instructions)
    result = 0
    run(instructions) do (time, register)
        if (time % 40 == 20)
            result += time * register
        end
    end
    result
end

function print_pixel((time, value))
    current_pixel = (time - 1) % 40
    print(abs(current_pixel - value) <= 1 ? '#' : ' ')
    if current_pixel == 39
        println()
    end
end

function part2(instructions)
    run(print_pixel, instructions)
end

untimed = untime(input)

untimed |> part1 |> println
untimed |> part2
