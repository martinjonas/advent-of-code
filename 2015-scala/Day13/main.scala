import scala.collection.mutable.HashMap
import scala.collection.mutable.HashSet

class PreferenceMap() {
  var preferences = new HashMap[(String, String), Int]()
  var people = new HashSet[String]()

  def setPreference(from: String, to: String, happinesss: Int) : Unit = {
    preferences((from, to)) = happinesss
    people += from
    people += to
  }

  def getPairPreference(person1: String, person2: String) : Int = {
      preferences((person1, person2)) + preferences((person2, person1))
  }

  def computeDistance(path : Seq[String]) : Int = {
    val pathPref = path.sliding(2).map(pair => getPairPreference(pair(0), pair(1))).sum
    val firstLastPref = getPairPreference(path.head, path.last)
    pathPref + firstLastPref
  }

  def findMinSeating() : Int = {
    people.toList.permutations.map(computeDistance).max
  }
}

object Day09
{
  def parseLine(line: String) : (String, String, Int) = {
    line.substring(0, line.length - 1).split(" ") match {
      // this is ugly, but it was the easiest modification from Day09
      case Array(from, _, what, happiness, _, _, _, _, _, _, to) =>
        return (from, to, if (what == "gain") { happiness.toInt } else { -happiness.toInt })
    }
  }

  def getMap(in: Vector[String]) : PreferenceMap = {
    var map = new PreferenceMap()

    for (line <- in) {
      val(from, to, dist) = parseLine(line)
      map.setPreference(from, to, dist)
    }

    map
  }

  def part1(map: PreferenceMap) : Int = map.findMinSeating()
  def part2(map: PreferenceMap) : Int = {
    for (person <- map.people) {
      map.setPreference("me", person, 0)
      map.setPreference(person, "me", 0)
    }

    map.findMinSeating()
  }

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector
    val map = getMap(lines)

    printf("Part 1: %d\n", part1(map))
    printf("Part 2: %d\n", part2(map))
  }
}
