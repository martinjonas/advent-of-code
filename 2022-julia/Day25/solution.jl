const filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

const values = Dict(
    '0' => 0,
    '1' => 1,
    '2' => 2,
    '-' => -1,
    '=' => -2)

const digits = Dict(val => digit for (digit, val) in values)

from_snafu(s) = foldl((acc, ch) -> 5*acc + values[ch], s; init=0)

function to_snafu(num)
    result = []
    while num != 0
        num, digit = divrem(num, 5, RoundNearest)
        pushfirst!(result, digits[digit])
    end
    join(result)
end

sum(from_snafu, input) |> to_snafu |> println
