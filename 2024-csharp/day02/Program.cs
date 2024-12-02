class Day02
{	
    static bool IsAlmostSafe(List<int> data)
    {
		return Enumerable.Range(0, data.Count() + 1).
            Any(i => IsSafe(data.Take(i).Concat(data.Skip(i + 1))));
    }

   static bool IsSafe(IEnumerable<int> data)
    {
        var differences = data.Zip(data.Skip(1), (x, y) => x - y);
        var first = differences.First();
        var isFirstValid = -3 <= first && first <= 3 && first != 0;

        return isFirstValid && (first > 0 ?
                              differences.All(x => 1 <= x && x <= 3) :
                              differences.All(x => -3 <= x && x <= -1));
    }
	
    static void Main(string[] args)
	{
		string inputFile = args.Length > 0 ? args[0] : "input";

		var data = File.ReadLines(inputFile)
			.Select(line => line.Split().Select(Int32.Parse).ToList())
			.ToList();

        var part1 = data.Count(IsSafe);
        Console.WriteLine(part1);

        var part2 = data.Count(IsAlmostSafe);
        Console.WriteLine(part2);
	}
}

