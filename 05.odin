package aoc05

import "core:fmt"
import "core:strings"
import "core:testing"

Line :: [2][2]int
input :: string(#load("05.txt"))

parse_line :: proc(s: string) -> Line {
  result := [4]int{}
  i := 0
  in_literal := true
  for c in s {
    switch c {
      case '0' .. '9':
      in_literal = true
      result[i] = result[i] * 10 + int(c - '0')
      case:
      if in_literal {i += 1}
      in_literal = false
    }
  }
  if i != 3 {
    fmt.printf("ERROR: got %d literals on line '%s' instead of 4\n", i + 1, s)
  }
  return transmute(Line)result
}

bake_hv :: proc(c: ^[$N][N]u8, l: ^Line) {
  if l[0].x == l[1].x || l[0].y == l[1].y {bake(c, l)}
}

bake :: proc(c: ^[$N][N]u8, l: ^Line) {
  x1, y1, x2, y2 := l[0].x, l[0].y, l[1].x, l[1].y
  n_steps := max(abs(x2 - x1), abs(y2 - y1))
  xdir := int(x2 > x1) - int(x2 < x1)
  ydir := int(y2 > y1) - int(y2 < y1)
  for i in 0 .. n_steps {c[x1 + xdir * i][y1 + ydir * i] += 1}
}

solve :: proc(lines: []Line, canvas: ^[$M][M]u8, part: int) {
  lines := lines
  for line, i in &lines {
    if part == 1 {bake_hv(canvas, &line)}
    else {bake(canvas, &line)}
  }
  result := 0
  for row in canvas {
    for entry in &row {
      if entry > 1 {result += 1}
    }
  }
  fmt.printf("Part 2: %d\n", result)
}

map_slice :: proc(a: []$T, p: proc(_: T) -> $F) -> []F {
  res := make([]F, len(a))
  for elem, i in a {res[i] = p(elem)}
  return res
}

main :: proc() {
  raw_lines := strings.split(strings.trim_space(input), "\n")
  lines := map_slice(raw_lines, parse_line)
  defer delete(lines)

  canvas := [1000][1000]u8{}
  solve(lines, &canvas, 1)
  canvas = {}
  solve(lines, &canvas, 2)
}

@(test)
sample_input :: proc(t: ^testing.T) {
  test_input := `0,9 -> 5,9
  8,0 -> 0,8
  9,4 -> 3,4
  2,2 -> 2,1
  7,0 -> 7,4
  6,4 -> 2,0
  0,9 -> 2,9
  3,4 -> 1,4
  0,0 -> 8,8
  5,5 -> 8,2`

  raw_lines := strings.split(strings.trim_space(test_input), "\n")
  lines := map_slice(raw_lines, parse_line)
  defer delete(lines)

  canvas := [10][10]u8{}
  solve(lines, &canvas, 1)
  canvas = {}
  solve(lines, &canvas, 2)
}
