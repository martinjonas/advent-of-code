import scala.collection.mutable.ArrayBuffer

class Reindeer(speed: Int, flyTime: Int, restTime: Int) {
  var currentFlyTime = 0
  var currentRestTime = 0
  var currentDistance = 0
  var points = 0

  def getDistance(duration: Int) : Int = {
    val cycleLength = (flyTime + restTime)
    val fullCycles = duration / cycleLength
    val remainingFlyTime = flyTime.min(duration % cycleLength)

    speed * (fullCycles * flyTime + remainingFlyTime)
  }

  def tick() = {
    if (currentFlyTime == flyTime && currentRestTime == restTime) {
      currentDistance += speed
      currentFlyTime = 1
      currentRestTime = 0
    } else if (currentFlyTime == flyTime) {
      currentRestTime += 1
    } else {
      currentDistance += speed
      currentFlyTime += 1
    }
  }
}

object Day14
{
  def parseLine(line: String) : Reindeer = {
    val parts = line.split(" ")
    new Reindeer(parts(3).toInt, parts(6).toInt, parts(13).toInt)
  }

  def part1(reindeers: Vector[Reindeer]) : Int = {
    reindeers.map(_.getDistance(2503)).max
  }

  def part2(reindeers: Vector[Reindeer]) : Int = {
    for (i <- 1 to 2503) {
      reindeers.foreach(_.tick())

      val maxDist = reindeers.map(_.currentDistance).max
      reindeers.filter(_.currentDistance == maxDist).foreach(_.points += 1)
    }

    reindeers.map(_.points).max
  }

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector
    val reindeers = lines.map(parseLine).toVector

    printf("Part 1: %d\n", part1(reindeers))
    printf("Part 2: %d\n", part2(reindeers))
  }
}
