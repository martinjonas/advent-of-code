object Day08
{
  val hexaLiteralRegex = raw"\\x([0-9a-f]{2})".r

  def parseStringEscaped(input: List[Char], acc: List[Char]) : List[Char] = {
    input match {
      case '\\' +: rest => parseStringLiteral(rest, '\\' :: acc)
      case '"' +: rest => parseStringLiteral(rest, '"' :: acc)
      case 'x' +: c1 +: c2 +: rest =>
        parseStringLiteral(rest, Integer.parseInt((c1.toString + c2.toString), 16).toChar :: acc)
      case Nil => acc
      case _ => throw new Exception("Unexpected escaped character");
    }
  }

  def parseStringLiteral(input: List[Char], acc: List[Char]) : List[Char] = {
    input match {
      case '\\' +: rest => parseStringEscaped(rest, acc)
      case ch +: rest => parseStringLiteral(rest, ch :: acc)
      case _ => acc
    }
  }

  def parseString(input: String) : String = {
    val contents = input.slice(1, input.length - 1)
    parseStringLiteral(contents.toList, Nil).mkString.reverse
  }

  def escapeString(input: String) : String = {
    "\"" + input.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
  }

  def part1(lines: Vector[String]) : Int = {
    val parsedLines = lines.map(parseString)
    lines.map(_.length).sum - parsedLines.map(_.length).sum
  }

  def part2(lines: Vector[String]) : Int = {
    val escapedLines = lines.map(escapeString)
    escapedLines.map(_.length).sum - lines.map(_.length).sum
  }

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector

    printf("Part 1: %d\n", part1(lines))
    printf("Part 2: %d\n", part2(lines))
  }
}
