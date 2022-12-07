import java.security.MessageDigest

object Day04
{
  def md5(s: String) = {
    MessageDigest.getInstance("MD5").digest(s.getBytes).map("%02X".format(_)).mkString
  }

  def findHash(in: String, zeroes: Int) = {
    LazyList.from(1).find(n => md5(in + n.toString()).startsWith("0" * zeroes)).get
  }

  def main(args: Array[String]) : Unit =
  {
    val input = "bgvyzdsv"

    printf("Part 1: %d\n", findHash(input, 5))
    printf("Part 2: %d\n", findHash(input, 6))
  }
}
