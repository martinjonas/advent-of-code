class Present (val lenght: Int, val width: Int, val height: Int)
{
  val sides = Array(lenght*width, width*height, lenght*height)
  val perimeters = Array(2*(lenght + width), 2*(width + height), 2*(lenght + height))

  def getArea() = 2 * sides.sum

  def getVolume() = lenght * width * height

  def getPaperArea() = getArea() + sides.min

  def getRibonLenght() = getVolume() + perimeters.min
}

object Day02
{
  def part1(in: Vector[Present]) = in.map(_.getPaperArea()).sum

  def part2(in: Vector[Present]) = in.map(_.getRibonLenght()).sum

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines()

    val presents = lines
      .map{_.split("x").map(_.toInt) }
      .map{parts => new Present(parts(0), parts(1), parts(2))}
      .toVector

    printf("Part 1: %d\n", part1(presents))
    printf("Part 2: %d\n", part2(presents))
  }
}
