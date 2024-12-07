class Day06
{
    static bool IsValid(long target, Span<long> numbers)
    {
        if (numbers.Length == 1) return numbers[0] == target;

        var last = numbers[^1];
        var init = numbers[0..^1];		
        return
            (last <= target && IsValid(target - last, init)) ||
			(target % last == 0 && IsValid(target / last, init));
    }

    static bool IsValidWithConcat(long target, Span<long> numbers)
    {
        if (numbers.Length == 1) return numbers[0] == target;

        var last = numbers[^1];
        var init = numbers[0..^1];
		int lastDigits = (int)Math.Floor(Math.Log10(last) + 1);
		long mod = (long)Math.Pow(10, lastDigits);

        return
            (last <= target && IsValidWithConcat(target - last, init)) ||
			(target % last == 0 && IsValidWithConcat(target / last, init)) ||
            (target % mod == last && IsValidWithConcat(target / mod, init));
    }
	
    static void Main(string[] args)
    {
        string inputFile = args.Length > 0 ? args[0] : "input";

        var data = File.ReadLines(inputFile)
			.Select(line => line.Split(": "))
			.Select(parts =>
					(long.Parse(parts[0]),
					 parts[1].Split().Select(long.Parse).ToArray()))
			.ToList();

        var part1 = data.Where(input => IsValid(input.Item1, input.Item2)).Sum(input => input.Item1);
        Console.WriteLine(part1);

        var part2 = data.Where(input => IsValidWithConcat(input.Item1, input.Item2)).Sum(input => input.Item1);
        Console.WriteLine(part2);
	}
}
