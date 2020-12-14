my $part1 = 0;
my $part2 = 0;

for 'input'.IO.lines -> $line {
    if $line ~~ m:s/(\d+)\-(\d+) (.)\: (.+)/ {
        $part1 += 1 if $0 <= $3.indices($2).elems <= $1;
        $part2 += 1 if ($3.substr($0-1, 1) eq $2) xor ($3.substr($1-1, 1) eq $2);
    }
}

say "Part 1: $part1";
say "Part 2: $part2";
