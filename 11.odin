package aoc11

import "core:fmt"
import "core:slice"
import "core:strings"

testing :: false 
when testing {
  steps :: 100
  input :: `5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526`
} else {
  steps :: 100
  input :: string(#load("11.txt"))
}

Board :: [10][10]u8

contains :: proc (v: ^[dynamic]int, e: int) -> bool {
  for f in v {if e == f {return true}}
  return false
}

update :: proc(b: ^Board, x, y: int, f: ^[dynamic]int) {
  offsets := [3]int{-1, 0, 1} 
  for i in offsets {
    for j in offsets {
      if 0 <= x + i && x + i < 10 &&
         0 <= y + j && y + j < 10 &&
         abs(i) + abs(j) != 0 &&
         !contains(f, x + i + 10 * (y + j)){
        b[y+j][x+i] = (b[y+j][x+i] + 1) % 10
        if (b[y+j][x+i] == 0) {append(f, x+i + 10*(y+j))}
      }
    }
  }
  return
}

part1 :: proc (board: ^Board) {
  board := board^
  n_flashes := 0
  flashes := [dynamic]int{}
  for t in 1..steps {
    clear(&flashes)
    for cell, p in cast(^[100]u8)(&board) {
      cell = (cell + 1) % 10
      if cell == 0 {append(&flashes, p)}
    }

    for p in flashes {
      x, y := p%10, p/10
      update(&board, x, y, &flashes)
    }
    n_flashes += len(flashes)
  }
  fmt.println(n_flashes)
}

part2 :: proc (board: ^Board) {
  board := board^
  flashes := [dynamic]int{}
  t := 0
  for ; len(flashes) < 100; t += 1 {
    clear(&flashes)
    for cell, p in cast(^[100]u8)(&board) {
      cell = (cell + 1) % 10
      if cell == 0 {append(&flashes, p)}
    }
    for p in flashes {
      x, y := p%10, p/10
      update(&board, x, y, &flashes)
    }
  }
  fmt.println(t)
}

main :: proc () {
  board := Board{}
  s, ok := strings.remove_all(input, "\n")
  defer delete(s)
  for r, i in s {board[i/10][i%10] = u8(r - '0')}

  part1(&board)
  part2(&board)
}
