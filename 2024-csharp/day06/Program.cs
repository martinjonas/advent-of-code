class Day06
{
    static (int, int) RotateRight((int x, int y) p) => (-p.y, p.x);
    static (int, int) Add((int x, int y) p1, (int x, int y) p2) => (p1.x + p2.x, p1.y + p2.y);
    static bool InBounds((int x, int y) p, int width, int height) => 0 <= p.x && p.x < width && 0 <= p.y && p.y < height;

    static HashSet<(int, int)> GetSeen(List<string> data, (int, int) start)
    {
        var height = data.Count();
        var width = data[0].Count();

        var dir = (0, -1);
        var current = start;
        var seen = new HashSet<(int, int)>();

        while (true)
        {
            seen.Add(current);

            (int col, int row) next = Add(current, dir);
			if (!InBounds(next, width, height)) return seen;
			
            if (data[next.row][next.col] == '#')
            {
                dir = RotateRight(dir);
            }
            else
            {
                current = next;
            }
        }		
    }
	
    static bool IsCyclic(List<string> data, (int, int) start, (int, int) blocked)
    {
        var height = data.Count();
        var width = data[0].Count();

        var north = (0, -1);
        var dir = north;
        var current = start;
        var seen = new HashSet<(int, int)>();

        while (true)
        {
            (int col, int row) next = Add(current, dir);
            if (!InBounds(next, width, height)) return false;

            if (data[next.row][next.col] == '#' || next == blocked)
            {
                if (dir == north)
                {
                    if (seen.Contains(current)) return true;
                    seen.Add(current);
                }
                dir = RotateRight(dir);
            }
            else
            {
                current = next;
            }
        }
    }

    static void Main(string[] args)
    {
        string inputFile = args.Length > 0 ? args[0] : "input";

        var data = File.ReadLines(inputFile).ToList();
        var height = data.Count();
        var width = data[0].Count();

        var (col, row, _) = data
            .SelectMany((items, row) => items.Select((ch, col) => (col, row, ch)))
            .Where(t => t.Item3 == '^')
            .First();

        var start = (col, row);
        var seen = GetSeen(data, start);
        Console.WriteLine(seen.Count());

        seen.Remove(start);
        var part2 = seen.Count(toBlock => IsCyclic(data, start, toBlock));
        Console.WriteLine(part2);
    }
}
