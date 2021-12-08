package aoc08

import "core:fmt"
import "core:strings"
import "core:slice"


testing :: false

when testing {
  input :: `be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce`
} else {
  input :: string(#load("08.txt"))
}

Entry :: struct {
  unique: []string,
  values: []string,
}

parse_entry :: proc (line: string) -> (result: Entry) {
  parts := strings.split(line, " | ")
  result.unique = strings.split(parts[0], " ")
  result.values = strings.split(parts[1], " ")
  return
}

part1 :: proc (entries: []Entry) {
  count := 0
  for e in entries {
    for digit in e.values {
      switch len(digit) {
        case 2, 3, 4, 7:
          count += 1
      }
    }
  }
  fmt.println("Part 1:", count)
}

Display :: distinct bit_set[1..7; u8]

parse_display :: proc (s: string) -> (result: Display) {
  for l in s { result += { int(l) - int('a') + 1} }
  return
}

count :: proc (d: Display) -> int {
  n := int(transmute(u8) d)
  count := 0
  for n > 0 { count += n & 1; n = n >> 1 }
  return count
}

make_lookup :: proc (u: []string) -> (digits: [10]Display) {
  int_5 := Display{1, 2, 3, 4, 5, 6, 7}
  int_6 := int_5
  for d in slice.mapper(u, parse_display, context.temp_allocator) { 
    switch count(d) {
      case 2: digits[1] = d
      case 3: digits[7] = d
      case 4: digits[4] = d
      case 7: digits[8] = d
      case 5: {int_5 &= d}
      case 6: {int_6 &= d}
    }
  }
  digits[2] = int_5 | (digits[8] &~ int_6)
  digits[3] = int_5 | digits[1]
  digits[5] = int_6 | int_5
  digits[6] = digits[5] | (digits[8] &~ digits[7])
  digits[9] = digits[4] | int_5
  digits[0] = (digits[5] ~ digits[2]) | int_6
  return
}

parse_int_from_segments :: proc (digits: []string, lookup: ^[10]Display) -> (res: int) {
  for d in slice.mapper(digits, parse_display, context.temp_allocator) {
    for l, i in lookup {
      if d == l { res = res * 10 + i; break }
    }
  }
  return
}

part2 :: proc (entries: []Entry) {
  total := 0
  for e in entries {
    l := make_lookup(e.unique)
    total += parse_int_from_segments(e.values, &l)
  }
  fmt.println("Part 2:", total)
}

main :: proc () {
  entries := slice.mapper(strings.split(strings.trim_space(input), "\n"), parse_entry)
  defer delete(entries)
  part1(entries)
  part2(entries)
}
