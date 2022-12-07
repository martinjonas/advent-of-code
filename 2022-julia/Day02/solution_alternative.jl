const input = readlines("input")

const p1 = ["B X", "C Y", "A Z", "A X", "B Y", "C Z", "C X", "A Y", "B Z"]
println(sum(input) do l findfirst(x -> l == x, p1) end)

const p2 = ["B X", "C X", "A X", "A Y", "B Y", "C Y", "C Z", "A Z", "B Z"]
println(sum(input) do l findfirst(x -> l == x, p2) end)
