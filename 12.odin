package aoc12

import "core:fmt"
import "core:slice"
import "core:strings"

when ODIN_DEBUG {
  input :: `start-A
start-b
A-c
A-b
b-d
A-end
b-end
`
} else {
  input :: string(#load("12.txt"))
}

cave :: struct { 
  big: bool,
  paths: [dynamic]int,
}

is_upper :: proc (s: string) -> bool {
  return 'A' <= (transmute([]u8)s)[0] && 
          (transmute([]u8)s)[0] <= 'Z'
}

cave_system :: [dynamic]cave

main :: proc () {
  cs := cave_system{cave{},cave{}}
  labels := map[string]int{ "start" = 0, "end" = 1}

  for line in strings.split(strings.trim_space(input), "\n") {
    s := strings.split(line, "-")
    for i in 0..1 {
      if s[i] not_in labels {
        append(&cs, cave{big = is_upper(s[i])})
        labels[s[i]] = len(cs) - 1
      }
    }
    append(&(cs[labels[s[0]]].paths), labels[s[1]])
    append(&(cs[labels[s[1]]].paths), labels[s[0]])
  }
  fmt.println(cs)
  fmt.println("Part1:", part1(cs[0], cs, {0}))
  fmt.println("Part1:", part2(cs[0], cs, {0}))
}

part1 :: proc (c: cave, cs: cave_system, visited: bit_set[0..63]) -> int {
  total_paths := 0
  for next in c.paths {
    switch {
      case next == 1:
        total_paths += 1
      case cs[next].big:
        fallthrough
      case next not_in visited:
        total_paths += part1(cs[next], cs, visited + {next})
    }
  }
  return total_paths
}

part2 :: proc (c: cave, cs: cave_system, visited: bit_set[0..63], jolly := true) -> int {
  total_paths := 0
  for next in c.paths {
    switch {
      case next == 0:
      case next == 1: 
        total_paths += 1
      case cs[next].big:
        total_paths += part2(cs[next], cs, visited, jolly)
      case next not_in visited:
        total_paths += part2(cs[next], cs, visited + {next}, jolly)
      case jolly:
        total_paths += part2(cs[next], cs, visited, false)
    }
  }
  return total_paths
}
