using Vec2D = (int x, int y);
public class Robot
{
    public Vec2D pos;
    public Vec2D velocity;
}

class Day14
{
    static int Width = 101;
	static int Height = 103;

	static Vec2D Add(Vec2D p1, Vec2D p2) => (p1.x + p2.x, p1.y + p2.y);
    static Vec2D Mul(Vec2D p, int k) => (p.x * k, p.y * k);
    static Vec2D Mod(Vec2D p1, Vec2D p2) => ((p1.x+p2.x) % p2.x, (p1.y+p2.y) % p2.y);	

    static int Part1(IEnumerable<Robot> data)
    {
        return data
            .Select(r => Mod(Add(r.pos, Mul(r.velocity, 100)), (Width, Height)))
            .Select(p => (x: int.Sign(p.x.CompareTo(Width / 2)), y: int.Sign(p.y.CompareTo(Height / 2))))
            .Where(p => p.x != 0 && p.y != 0)
            .GroupBy(x => x)
            .Aggregate(1, (acc, g) => acc * g.Count());
    }

	static int Part2(List<Robot> robots)
    {
        var move = (Robot r) => Mod(Add(r.pos, r.velocity), (Width, Height));

        int steps = 0;
        while (true)
        {
            steps++;
            for (int i = 0; i < robots.Count; i++)
            {
                robots[i].pos = move(robots[i]);
            }

            var robotSet = new HashSet<Vec2D>(robots.Select(r => r.pos));

            var hasLine = Enumerable.Range(0, Width).Any(
                startx => Enumerable.Range(0, Height).Any(
                    starty => Enumerable.Range(0, 10).All(
                        y => robotSet.Contains((startx, starty + y)))));

            if (hasLine)
			{
				Print(robotSet);
				return steps;
            }
        }
    }

    static void Print(HashSet<Vec2D> positions)
    {
        for (int y = 0; y < Height; y++)
        {
            for (int x = 0; x < Width; x++)
            {
                Console.Write(positions.Contains((x, y)) ? 'X' : ' ');
            }
            Console.WriteLine();
        }
    }

    static void Main(string[] args)
    {
		string inputFile = args.Length > 0 ? args[0] : "input";

        var data = File.ReadLines(inputFile)
            .Select(line => line.Split(' ').Select(p => p.Split('=')[1].Split(",").Select(int.Parse).ToArray()).ToArray())
			.Select(p => new Robot{
					pos = (p[0][0], p[0][1]),
					velocity = Mod((p[1][0], p[1][1]), (Width, Height)) })
            .ToList();

        Console.WriteLine(Part1(data));
        Console.WriteLine(Part2(data));		
    }
}
