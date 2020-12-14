defmodule Day2 do
  def is_valid_1(n1, n2, ch, pass) do
    occurences = String.graphemes(pass)
    |> Enum.filter(fn codepoint -> codepoint == ch end)
    |> Enum.count

    n1 <= occurences and occurences <= n2
  end

  def is_valid_2(n1, n2, ch, pass) do
    (String.at(pass, n1 - 1) == ch) != (String.at(pass, n2 - 1) == ch)
  end
end

rules = "input"
|> File.stream!()
|> Stream.map(&String.trim_trailing/1)
|> Stream.map(fn line -> String.split(line, [": ", "-", " "]) end)
|> Stream.map(fn [n1, n2, ch, pass] -> [String.to_integer(n1), String.to_integer(n2), ch, pass] end)
|> Enum.into([])

IO.write("Part 1: ")
IO.puts(rules |> Enum.filter(fn rule -> apply(&Day2.is_valid_1/4, rule) end) |> Enum.count)

IO.write("Part 2: ")
IO.puts(rules |> Enum.filter(fn rule -> apply(&Day2.is_valid_2/4, rule) end) |> Enum.count)
