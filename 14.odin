package aoc14

import "core:strings"
import "core:fmt"

main :: proc () {
  splits := strings.split(strings.trim_space(input), "\n\n")
  seq := transmute([]u8)splits[0]
  rules := map[[2]u8]u8{}
  for line in strings.split(splits[1], "\n") {
    bytes := transmute([]u8)line
    rules[{ bytes[0], bytes[1] }] = bytes[6]
  }
  solve(seq, rules, 10)
  solve(seq, rules, 40)
}

solve :: proc (seq: []u8, rules: map[[2]u8]u8, nsteps: int) {
  pairs := map[[2]u8]int{}
  for i in 0..<len(seq)-1 {
    key := [2]u8{seq[i], seq[i+1]}
    pairs[key] += 1
  }
  for _ in 1..nsteps {
    new_pairs := map[[2]u8]int{}
    for pair in pairs {
      if pair in rules {
        new_pairs[{pair[0], rules[pair]}] += pairs[pair]
        new_pairs[{rules[pair], pair[1]}] += pairs[pair]
      } else {
        new_pairs[pair] += pairs[pair]
      }
    }
    delete(pairs)
    pairs = new_pairs
  }
  counts := map[u8]int{}
  counts[seq[0]] = 1
  for key in pairs {
    counts[key[1]] += pairs[key]
  }

  minimum, maximum := max(int),  0
  for key in counts {
    minimum = min(counts[key], minimum)
    maximum = max(counts[key], maximum)
  }

  fmt.println(nsteps,"steps:", maximum - minimum)
}


when ODIN_DEBUG {
  input := `NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
`
} else {
  input := string(#load("14.txt"))
}
