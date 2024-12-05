class Day05
{
    static bool IsValidUpdateSequence(IEnumerable<int> values, Dictionary<int, List<int>> dependencies)
    {
        var allValues = new HashSet<int>(values);
        var seen = new HashSet<int>();
        foreach (var u in values)
        {
            if (dependencies.ContainsKey(u) && dependencies[u].Any(d => allValues.Contains(d) && !seen.Contains(d)))
                return false;

            seen.Add(u);
        }
        return true;
    }

    static List<int> SortCorrectly(IEnumerable<int> values, Dictionary<int, List<int>> dependencies)
    {
        var result = new List<int>();
        var toProcess = new Queue<int>(values);
        var allValues = new HashSet<int>(values);
        var added = new HashSet<int>();
        while (toProcess.Count() > 0)
        {
            var cur = toProcess.Dequeue();
            if (dependencies.ContainsKey(cur) && dependencies[cur].Any(d => allValues.Contains(d) && !added.Contains(d)))
            {
                toProcess.Enqueue(cur);
            }
            else
            {
                result.Add(cur);
                added.Add(cur);
            }
        }

        return result;
    }

    static void Main(string[] args)
    {
        string inputFile = args.Length > 0 ? args[0] : "input";

        var data = File.ReadLines(inputFile).ToList();

        var dependencies = data
            .TakeWhile(s => s != "")
            .Select(s => s.Split('|').Select(int.Parse).ToArray())
            .GroupBy(parts => parts[1], parts => parts[0])
            .ToDictionary(g => g.Key, g => g.ToList());

        var updates = data
            .SkipWhile(s => s != "")
            .Skip(1)
            .Select(s => s.Split(',').Select(int.Parse).ToArray());

        var part1 = updates
            .Where(u => IsValidUpdateSequence(u, dependencies))
            .Select(u => u[u.Count() / 2])
            .Sum();
        Console.WriteLine(part1);

        var part2 = updates
            .Where(u => !IsValidUpdateSequence(u, dependencies))
            .Select(u => SortCorrectly(u, dependencies))
            .Select(u => u[u.Count() / 2])
            .Sum();
        Console.WriteLine(part2);
    }
}
