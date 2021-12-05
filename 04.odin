package main

import libc "core:c/libc"
import "core:fmt"
import "core:strings"
import "core:strconv"

input :: string(#load("./04.txt"));

Table :: distinct [5][5]u8

Result :: struct { turn: int, score: int }

parse_table :: proc (s: string) -> Table {
  t := Table{}
  for line, i in strings.split(s, "\n") {
    if i > 4 do break
    libc.sscanf(strings.unsafe_string_to_cstring(line),"%d %d %d %d %d", 
      &t[i][0], &t[i][1], &t[i][2], &t[i][3], &t[i][4])
  }
  return t
}

turn_and_score :: proc (tab: ^Table, numbers: []u8) -> Result {
  found := [5][5]b8{}
  extract: for num, turn in numbers {
    for i in 0..4 {
      for j in 0..4 {
        if tab[i][j] == num {
          found[i][j] = true
          if complete(found[:]) do return Result{ turn, score(tab, found[:], num) }
          continue extract
        }
      }
    }
  }
  return Result { -1, -1 }
}

complete :: proc (f: [][5]b8) -> bool {
  row: for i in 0..4 {
    for j in 0..4 do if !f[i][j] do continue row
    return true
  }
  col: for j in 0..4 {
    for i in 0..4 do if !f[i][j] do continue col 
    return true
  }
  return false
}

score :: proc (t: ^Table, f: [][5]b8, n: u8) -> int {
  res := 0
  for i in 0..4 do for j in 0..4 do if !f[i][j] do res += int(t[i][j])
  return res * int(n)
}

part_1 :: proc (results: []Result) {
  best := Result{-1, -1}
  for res in results {
    if  best.turn == -1 || res.turn < best.turn do best = res
  }
  fmt.printf("Part 1: win at turn %d with score %d\n", best.turn, best.score)
}

part_2 :: proc (results: []Result) {
  best := Result{-1, -1}
  for res in results {
    if  best.turn == -1 || res.turn > best.turn do best = res
  }
  fmt.printf("Part 2: win at turn %d with score %d\n", best.turn, best.score)
}

main :: proc () {
  parts := strings.split(input, "\n\n")

  numbers := [dynamic]u8{}
  defer delete(numbers)
  for num in strings.split(parts[0], ",") { 
    t, _ := strconv.parse_int(num)
    append(&numbers , u8(t))
  }

  results := [dynamic]Result{}
  defer delete(results)
  for mat in parts[1:] {
    tab := parse_table(mat)
    append(&results, turn_and_score(&tab, numbers[:])) 
  }

  part_1(results[:])
  part_2(results[:])
}
