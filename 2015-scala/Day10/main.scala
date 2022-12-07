object Day10
{
  def groupSuccessive[T](seq: List[T]) : List[(T, Int)] = {
    def groupSuccessiveAcc(seq: List[T], acc: List[(T, Int)]) : List[(T, Int)] = {
      seq match {
        case Nil => acc
        case x::xs =>
          acc match {
            case Nil => groupSuccessiveAcc(xs, (x, 1) :: Nil)
            case (v, n) :: rest =>
              if (v == x) {
                groupSuccessiveAcc(xs, (v, n+1) :: rest)
              } else {
                groupSuccessiveAcc(xs, (x, 1) :: (v, n) :: rest)
              }
          }
      }
    }

    groupSuccessiveAcc(seq, Nil).reverse
  }

  def step(seq: List[Int]) : List[Int] = {
    groupSuccessive(seq).flatMap { case (n, v) => List(v, n) }
  }

  def bothParts(seq: List[Int], iterations: Int) : Int = {
    var current = seq

    for (i <- 1 to iterations) {
      current = step(current)
    }

    current.length
  }

  def main(args: Array[String]) : Unit =
  {
    val input = "1113122113".toList.map(_.toString.toInt)

    printf("Part 1: %d\n", bothParts(input, 40))
    printf("Part 1: %d\n", bothParts(input, 50))

    // needs to be run with -J-Xmx2g
  }
}
