import scala.collection.mutable.HashMap
import scala.collection.mutable.HashSet

class Map() {
  var distances = new HashMap[(String, String), Int]()
  var cities = new HashSet[String]()

  def setDistance(from: String, to: String, dist: Int) : Unit = {
    distances((from, to)) = dist
    distances((to, from)) = dist

    cities += from
    cities += to
  }

  def computeDistance(path : Seq[String]) : Int = {
    path.sliding(2).map(pair => distances((pair(0), pair(1)))).sum
  }

  def findMinHamiltonianPath() : Int = {
    cities.toList.permutations.map(computeDistance).min
  }

  def findMaxHamiltonianPath() : Int = {
    cities.toList.permutations.map(computeDistance).max
  }
}

object Day09
{
  def parseLine(line: String) : (String, String, Int) = {
    line.split(" ") match {
      case Array(from, "to", to, "=", dist) =>
        return (from, to, dist.toInt)
    }
  }

  def getMap(in: Vector[String]) : Map = {
    var map = new Map()

    for (line <- in) {
      val(from, to, dist) = parseLine(line)
      map.setDistance(from, to, dist)
    }

    map
  }

  def part1(map: Map) : Int = map.findMinHamiltonianPath()
  def part2(map: Map) : Int = map.findMaxHamiltonianPath()

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector
    val map = getMap(lines)

    printf("Part 1: %d\n", part1(map))
    printf("Part 1: %d\n", part2(map))
  }
}
