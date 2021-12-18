package aoc12

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:time"

ITERATIVE :: false 

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
    fmt.println("Part1:", part1(cs[0], cs, {0}))
    fmt.println("Part2:", part2(cs[0], cs, {0}))

    fmt.println("Part1_iterative:", part1_iterative(cs))
    fmt.println("Part2_iterative:", part2_iterative(cs))
}

part1 :: proc "contextless" (c: cave, cs: cave_system, visited: bit_set[0..63]) -> int #no_bounds_check {
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

part1_iterative :: proc (cs: cave_system) -> (total_paths: int) #no_bounds_check {
  Frame :: struct {
    cave: int,
    visited: bit_set[0..63],
    next_neighbour: int,
  }
  // starts at cave 0 with 0 as only visited cave and 0 as next neighbour to explore
  path := [dynamic]Frame{ Frame{0, {0}, 0} } 
  defer delete(path)

  for {
    f := &path[len(path) - 1]
    if f.cave == 1 { total_paths += 1; pop(&path); continue }
    if f.next_neighbour == len(cs[f.cave].paths) { 
      pop(&path)
      if len(path) == 0 {return total_paths}
      continue
    }

    potential_next := cs[f.cave].paths[f.next_neighbour]
    if cs[potential_next].big || potential_next not_in f.visited {
      f.next_neighbour += 1
      append(&path, Frame{potential_next, f.visited + {potential_next}, 0})
      continue
    }
    f.next_neighbour += 1
  }

  return total_paths
}

part2 :: proc "contextless" (c: cave, cs: cave_system, visited: bit_set[0..63], jolly := true) -> int #no_bounds_check{
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

part2_iterative :: proc (cs: cave_system) -> (total_paths: int) #no_bounds_check {
  Frame :: struct {
    cave: int,
    visited: bit_set[0..63],
    next_neighbour: int,
    jolly: bool,
  }
  // starts at cave 0 with 0 as only visited cave, 0 as next neighbour to explore, and jolly
  path := [dynamic]Frame{ Frame{0, {0}, 0, true} } 
  defer delete(path)

  for {
    f := &path[len(path) - 1]

    if f.cave == 1 { total_paths += 1; pop(&path); continue }
    if f.next_neighbour == len(cs[f.cave].paths) { 
      pop(&path)
      if len(path) == 0 {return total_paths}
      continue
    }

    potential_next := cs[f.cave].paths[f.next_neighbour]
    if cs[potential_next].big || potential_next not_in f.visited {
      f.next_neighbour += 1
      append(&path, Frame{potential_next, f.visited + {potential_next}, 0, f.jolly})
      continue
    }

    if f.jolly && potential_next != 0 {
      f.next_neighbour += 1
      append(&path, Frame{potential_next, f.visited + {potential_next}, 0, false})
      continue
    }

    f.next_neighbour += 1
  }

  return total_paths
}
