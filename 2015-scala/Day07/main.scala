import scala.collection.mutable.HashMap

sealed abstract class Gate

object Gate {
  final case class Signal(name: String) extends Gate
  final case class Input(value: Char) extends Gate
  final case class And(in1: Gate, in2: Gate) extends Gate
  final case class Or(in1: Gate, in2: Gate) extends Gate
  final case class Not(in1: Gate) extends Gate
  final case class Lshift(in1: Gate, in2: Gate) extends Gate
  final case class Rshift(in1: Gate, in2: Gate) extends Gate
}

class Circuit {
  var gates = new HashMap[String, Gate]()
  var cache = new HashMap[Gate, Char]()
  var overrides = new HashMap[String, Char]()

  def addGate(signal: String, g: Gate) : Unit = gates(signal) = g

  def eval(signal: String) : Char = eval(gates(signal))

  def eval(signal: Gate) : Char = {
    if (cache contains signal)
      return cache(signal)

    val result : Char = signal match {
      case Gate.Signal(name) => overrides.getOrElse(name, eval(name))
      case Gate.Input(value) => value
      case Gate.And(in1, in2) => (eval(in1) & eval(in2)).toChar
      case Gate.Or(in1, in2) => (eval(in1) | eval(in2)).toChar
      case Gate.Not(in) => (~eval(in)).toChar
      case Gate.Lshift(in1, in2) => (eval(in1) << eval(in2)).toChar
      case Gate.Rshift(in1, in2) => (eval(in1) >> eval(in2)).toChar
    }

    cache(signal) = result
    result
  }

  def override_signal(signal: String, value: Char) = {
    overrides(signal) = value
    cache.clear()
  }
}

object Day07
{
  def opToCtor(op: String) : ((Gate, Gate) => Gate) = op match {
    case "AND" => return Gate.And
    case "OR" => return Gate.Or
    case "LSHIFT" => return Gate.Lshift
    case "RSHIFT" => return Gate.Rshift
  }

  def parseInput(input: String) : Gate = {
    if (input(0).isLower) { new Gate.Signal(input) } else { new Gate.Input(input.toInt.toChar) }
  }

  def parseLine(line: String) : (String, Gate) = {
    line.split(" ") match {
      case Array(input, "->", target) =>
        return (target, parseInput(input))
      case Array(in1, op, in2, "->", target) =>
        return (target, opToCtor(op)(parseInput(in1), parseInput(in2)))
      case Array("NOT", input, "->", target) =>
        return (target, new Gate.Not(new Gate.Signal(input)))
    }
  }

  def getCircuit(in: Vector[String]) : Circuit = {
    var c = new Circuit()

    for (line <- in) {
      val(signal, g) = parseLine(line)
      c.addGate(signal, g)
    }

    c
  }

  def part1(circuit: Circuit) : Int = circuit.eval("a")

  def part2(circuit: Circuit) : Int = {
    val a_val = circuit.eval("a")
    circuit.override_signal("b", a_val)
    circuit.eval("a")
  }

  def main(args: Array[String]) : Unit =
  {
    val lines = scala.io.Source.fromFile("input").getLines().toVector
    val circuit = getCircuit(lines)

    printf("Part 1: %d\n", part1(circuit))
    printf("Part 2: %d\n", part2(circuit))
  }
}
