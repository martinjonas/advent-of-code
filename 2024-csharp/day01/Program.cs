using System.Collections.Generic;

class Day01
{
    static void Main(string[] args)
    {
		string inputFile = args.Length > 0 ? args[0] : "input";
		
		var g1 = new List<int>();
		var g2 = new List<int>();
		var g2counts = new Dictionary<int, int>();
		
		var lines = File.ReadLines(inputFile);
		foreach (var line in lines)
		{
			var parts = line.Split(' ', StringSplitOptions.RemoveEmptyEntries);
			var v1 = Int32.Parse(parts[0]);
			var v2 = Int32.Parse(parts[1]);
			
			g1.Add(v1);
			g2.Add(v2);

			g2counts.TryAdd(v2, 0);
			g2counts[v2] = g2counts[v2] + 1;			
		}

		g1.Sort();
        g2.Sort();

		var part1 = g1.Zip(g2, (l, r) => Int32.Abs((l - r))).Sum();
		Console.WriteLine(part1);

		var part2 = g1.Select((v1) => v1 * g2counts.GetValueOrDefault(v1, 0)).Sum();
		Console.WriteLine(part2);		
	}
}

