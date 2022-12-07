defmodule Day1 do
  def sum2(numbers, target) do
    n1 = numbers |> Enum.find(fn n -> MapSet.member?(numbers, target - n) end)
    if n1 do [n1, target - n1] end
  end

  def sum3(numbers, target) do
    [n1, n2] = numbers |> Enum.find_value(fn n -> sum2(numbers, target - n) end)
    [n1, n2, target - n1 - n2]
  end
end

numbers = "input"
  |> File.stream!()
  |> Stream.map(fn line -> {num,_} = Integer.parse(line); num end)
  |> Enum.into(MapSet.new())

IO.write("Part 1: ")
IO.puts(Day1.sum2(numbers, 2020) |> Enum.reduce(&*/2))
IO.write("Part 2: ")
IO.puts(Day1.sum3(numbers, 2020) |> Enum.reduce(&*/2))
