class Day06
{
    static bool IsValid(long target, Span<long> numbers, bool allowConcat)
    {
        if (numbers.Length == 1) return numbers[0] == target;

        var last = numbers[^1];
        var init = numbers[0..^1];
        int lastDigits = (int)Math.Floor(Math.Log10(last) + 1);
        long mod = (long)Math.Pow(10, lastDigits);

        return
            (last <= target && IsValid(target - last, init, allowConcat)) ||
            (target % last == 0 && IsValid(target / last, init, allowConcat)) ||
            (allowConcat && target % mod == last && IsValid(target / mod, init, allowConcat));
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

        var part1 = data.Where(input => IsValid(input.Item1, input.Item2, false)).Sum(input => input.Item1);
        Console.WriteLine(part1);

        var part2 = data.Where(input => IsValid(input.Item1, input.Item2, true)).Sum(input => input.Item1);        
        Console.WriteLine(part2);
    }
}
