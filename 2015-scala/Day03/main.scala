import collection.mutable.HashSet

class Map
{
  var x = 0
  var y = 0

  var seen = HashSet((0,0))

  def move(command : Char) : Unit = {
    command match {
      case '<' => x -= 1
      case '>' => x += 1
      case '^' => y -= 1
      case 'v' => y += 1
    }

    seen += ((x, y))
  }

  def move(commands : String) : Unit = commands.foreach(move)
}

object Day03
{
  def part1(in: String) = {
    var map = new Map()
    map.move(in)
    map.seen.size
  }

  def part2(in: String) = {
    var map1 = new Map()
    var map2 = new Map()

    val(c1, c2) = in.sliding(2,2).map(s => (s(0), s(1))).toSeq.unzip

    map1.move(c1.mkString)
    map2.move(c2.mkString)

    (map1.seen ++ map2.seen).size
  }

  def main(args: Array[String]) : Unit =
  {
    val input = scala.io.Source.fromFile("input").mkString

    printf("Part 1: %d\n", part1(input))
    printf("Part 2: %d\n", part2(input))
  }
}
