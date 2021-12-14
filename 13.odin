package aoc13

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"


Dot :: distinct [2]int
Direction :: enum { X, Y }
Fold :: struct { d: Direction, off: int }

parse_dot :: proc(input: string) -> Dot {
  splits := strings.split(input, ",")
  defer delete(splits)
  return Dot {
    strconv.parse_int(splits[0]) or_else 0,
    strconv.parse_int(splits[1]) or_else 0,
  }
}

parse_fold :: proc (input: string) -> Fold {
  num := strconv.parse_int(input[13:]) or_else 0
  dir := (transmute([]u8)input)[11]
  switch dir {
    case 'x':
      return Fold { .X, num }
    case 'y':
      return Fold { .Y, num }
  }
  return Fold{}
}

main :: proc () {
  splits := strings.split(strings.trim_space(input), "\n\n")
  dots := slice.mapper(strings.split(splits[0], "\n"), parse_dot)
  folds := slice.mapper(strings.split(splits[1], "\n"), parse_fold)

  part1(dots, folds)
  part2(dots, folds)
}

dot_cmp :: proc (i, j: Dot) -> slice.Ordering {
  if i.x != j.x {
    return slice.Ordering(int(i.x > j.x) - int(i.x < j.x))
  }
  return slice.Ordering(int(i.y > j.y) - int(i.y < j.y))
}

part1 :: proc (dots: []Dot, folds: []Fold) {
  dots := slice.to_dynamic(dots)
  fold := folds[0]
  for dot in &dots {
    switch fold.d {
      case .X:
        dot.x = fold.off - abs(dot.x - fold.off)
      case .Y:
        dot.y = fold.off - abs(dot.y - fold.off)
    }
  }
  slice.sort_by_cmp(dots[:], dot_cmp)
  uniq := 1
  for i in 1..<len(dots) {
    if dots[i] != dots[i-1] {uniq+=1}
  }
  fmt.println("Part1:", uniq)
}

part2 :: proc (dots: []Dot, folds: []Fold) {
  dots := slice.to_dynamic(dots)
  for fold in folds {
    for dot in &dots {
      switch fold.d {
        case .X:
          dot.x = fold.off - abs(dot.x - fold.off)
        case .Y:
          dot.y = fold.off - abs(dot.y - fold.off)
      }
    }
  }

  canvas : [5 * 8][6]u8 ='.'
  for dot in dots { canvas[dot.x][dot.y] = '#' }
  for line in &canvas { fmt.println(string(line[:])) }
}


when ODIN_DEBUG {
  input :: `6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
`
} else {
  input :: string(#load("13.txt"))
}
