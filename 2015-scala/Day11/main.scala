object Day10
{
  def getNextChar(c: Char) : Char = {
    val res = (c+1).toChar
    val isInValid = (res == 'i' || res == 'o' || res == 'l')
    if (isInValid) (res+1).toChar else res
  }

  def getNextStr(str: String) : String = {
    val lastNonZ = str.lastIndexWhere(c => c != 'z')
    str.zipWithIndex
      .map { case (c, i) => if (i < lastNonZ) { c } else if (i == lastNonZ) { getNextChar(c) } else {'a'} }
      .mkString
  }

  def getNextStrFromInvalid(str: String) : String = {
    val firstInvalid = str.indexWhere(c => (c == 'i' || c == 'o' || c == 'l'))

    if (firstInvalid == -1)
      return getNextStr(str)

    str.zipWithIndex
      .map { case (c, i) => if (i < firstInvalid) { c } else if (i == firstInvalid) { getNextChar(c) } else {'a'} }
      .mkString
  }

  def isValidPass(pass: String) : Boolean = {
    pass.sliding(3).exists(seq => (seq(1) - seq(0) == 1) && (seq(2) - seq(1) == 1)) &&
    pass.sliding(2).filter(seq => (seq(1) == seq(0))).distinct.size > 1
  }

  def getNextPass(pass: String) : String = {
    LazyList.iterate(getNextStrFromInvalid(pass)){getNextStr}.find{isValidPass}.get
  }

  def main(args: Array[String]) : Unit =
  {
    val input = "hxbxwxba"

    val part1 = getNextPass(input)
    printf("Part 1: %s\n", part1)
    printf("Part 2: %s\n", getNextPass(part1))
  }
}
