object Day01 {

  def part1(in: String) : Int =
  {
    in.foldRight(0) {
      (c, f) => if (c == '(') { f + 1 } else { f - 1 }
    }
  }

  def part2(in: String) : Int =
  {
    val floors = in.scanLeft(0) {
      (f, c) => if (c == '(') { f + 1 } else { f - 1 }
    }

    floors.indexOf(-1)
  }

  def main(args: Array[String]) : Unit =
  {
    val input = scala.io.Source.fromFile("input").mkString

    printf("Part 1: %d\n", part1(input))
    printf("Part 2: %d\n", part2(input))
  }

}
