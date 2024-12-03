using System.Text.RegularExpressions;

class Day03
{
    static void Main(string[] args)
    {
        string inputFile = args.Length > 0 ? args[0] : "input";

        var data = File.ReadAllText(inputFile);

        var pattern = @"mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)";

        var part1 = 0;
		var part2 = 0;
        var enabled = true;
        foreach (Match match in Regex.Matches(data, pattern))
        {
            if (match.Value == "do()")
            {
                enabled = true;
                continue;
            }

			if (match.Value == "don't()")
            {
                enabled = false;
                continue;
            }
			
			part1 += int.Parse(match.Groups[1].Value) * int.Parse(match.Groups[2].Value);
			if (enabled)
            {
                part2 += int.Parse(match.Groups[1].Value) * int.Parse(match.Groups[2].Value);
            }			
        }
        Console.WriteLine(part1);
        Console.WriteLine(part2);		
    }
}
