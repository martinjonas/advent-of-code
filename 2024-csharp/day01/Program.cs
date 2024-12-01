class Day01
{
	static void Main(string[] args)
	{
		string inputFile = args.Length > 0 ? args[0] : "input";

		var data = File.ReadLines(inputFile)
			.Select(line => line.Split(' ', StringSplitOptions.RemoveEmptyEntries).Select(Int32.Parse).ToList())
			.ToList();
		
		var g1 = data.Select(l => l[0]).ToList();
		var g2 = data.Select(l => l[1]).ToList();

		g1.Sort();
		g2.Sort();

		var part1 = g1.Zip(g2, (l, r) => Int32.Abs(l - r)).Sum();
		Console.WriteLine(part1);

		var g2counts = g2.GroupBy(n => n).ToDictionary(g => g.Key, g => g.Count());
		var part2 = g1.Select(v1 => v1 * g2counts.GetValueOrDefault(v1, 0)).Sum();
        Console.WriteLine(part2);
    }
}

