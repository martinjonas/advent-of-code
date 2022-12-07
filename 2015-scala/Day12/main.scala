object Day12
{
  def part1(jsonStr: String) : Integer = {
//    json.map(c => if (c.isDigit || c == '-') { c } else { ' ' })
//      .split(' ').filter(_.length > 0)
//      .map(_.toInt).sum
    val json = JSON.parseFull(jsonStr)
    42
  }

  def main(args: Array[String]) : Unit =
  {
    val input = io.Source.fromFile("input").mkString

    printf("Part 1: %d\n", part1(input))
  }
}
