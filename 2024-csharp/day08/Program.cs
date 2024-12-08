using Point = (int x, int y);

class Day08
{
    static int Width;
	static int Height;

    static Point Add(Point p1, Point p2) => (p1.x + p2.x, p1.y + p2.y);
	static Point Sub(Point p1, Point p2) => (p1.x - p2.x, p1.y - p2.y);
    static bool InBounds(Point p) => 0 <= p.x && p.x < Width && 0 <= p.y && p.y < Height;
	
    static IEnumerable<Point> GetExactAntinodes(Point a1, Point a2)
    {
        var pos = Add(a2, Sub(a2, a1));
        if (InBounds(pos)) yield return pos;
    }

	static IEnumerable<Point> GetLineAntinodes(Point a1, Point a2)
    {
        var diff = Sub(a2, a1);
        var pos = a1;
        while (InBounds(pos))
        {
            yield return pos;
            pos = Add(pos, diff);
        }
    }

    static int CountAntinodes(Dictionary<char, List<(int, int)>> data, Func<Point, Point, IEnumerable<Point>> antinodeFunction)
	{		
        return data.SelectMany(
            kvp => kvp.Value.SelectMany(a1 => kvp.Value.Where(a2 => a1 != a2).SelectMany(a2 => antinodeFunction(a1, a2))))
			.Distinct()
			.Count();
	}
    
    static void Main(string[] args)
    {
        string inputFile = args.Length > 0 ? args[0] : "input";

        var lines = File.ReadLines(inputFile).ToList();
		var data = lines
            .SelectMany((s, row) => s.Select((ch, col) => (value: ch, pos: (col, row))))
            .Where(x => x.value != '.')
            .GroupBy(x => x.value, x => x.pos)
            .ToDictionary(x => x.Key, x => x.ToList());

        Width = lines.Count();
        Height = lines[0].Count();

        Console.WriteLine(CountAntinodes(data, GetExactAntinodes));
        Console.WriteLine(CountAntinodes(data, GetLineAntinodes));		
    }
}
