import scala.reflect.ClassTag

abstract class Lights[T: ClassTag] {
  var state = Array.ofDim[T](1000,1000)

  val lineRegex = raw"(.*) (\d+),(\d+) through (\d+),(\d+)".r

  def apply(x1: Int, y1: Int, x2: Int, y2: Int, f: (Int, Int) => Unit) =
  {
    for (x <- x1 to x2)
      for (y <- y1 to y2)
        f(x, y)
  }

  def applyString(s: String) = s match {
    case lineRegex(command, x1, y1, x2, y2) => {
      val fun = command match {
        case "turn on" => turnOn(_,_)
        case "turn off" => turnOff(_,_)
        case "toggle" => toggle(_,_)
      }

      apply(x1.toInt, y1.toInt, x2.toInt, y2.toInt, fun)
    }
  }

  def toggle(x: Int, y: Int) : Unit
  def turnOff(x: Int, y: Int) : Unit
  def turnOn(x: Int, y: Int) : Unit
}

class BooleanLights extends Lights[Boolean] {
  def toggle(x: Int, y: Int) = state(x)(y) = !state(x)(y)
  def turnOff(x: Int, y: Int) = state(x)(y) = false
  def turnOn(x: Int, y: Int) = state(x)(y) = true

  def countTurnedOn = state.map(line => line.count(x => x)).sum
}

class IntegralLights extends Lights[Int] {
  def toggle(x: Int, y: Int) = state(x)(y) += 2
  def turnOff(x: Int, y: Int) = state(x)(y) = 0 max state(x)(y) - 1
  def turnOn(x: Int, y: Int) = state(x)(y) += 1

  def countTurnedOn = state.map(line => line.sum[Int]).sum
}

object Day05
{
  def part1(in: Vector[String]) = {
    var lights = new BooleanLights()

    for (l <- in)
      lights.applyString(l)

    lights.countTurnedOn
  }

  def part2(in: Vector[String]) = {
    var lights = new IntegralLights()

    for (l <- in)
      lights.applyString(l)

    lights.countTurnedOn
  }

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector

    printf("Part 1: %d\n", part1(lines))
    printf("Part 2: %d\n", part2(lines))
  }
}
