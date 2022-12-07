object Day05
{
  val threeWovelsRegex = raw".*([aeiou].*){3,}".r
  val twiceSameRegex = raw".*(.)\1.*".r
  val bannedRegex = raw".*(ab|cd|pq|xy).*".r

  def part1(in: Vector[String]) =
    in.count(s => threeWovelsRegex.matches(s) && twiceSameRegex.matches(s) & !bannedRegex.matches(s))

  val twoSamePairsRegex = raw".*(..).*\1.*".r
  val sandwichRegex = raw".*(.).\1.*".r

  def part2(in: Vector[String]) =
    in.count(s => twoSamePairsRegex.matches(s) && sandwichRegex.matches(s))

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector

    printf("Part 1: %d\n", part1(lines))
    printf("Part 2: %d\n", part2(lines))
  }
}
