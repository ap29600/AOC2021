package aoc20

import "core:fmt"
import "core:slice"
import "core:strings"


Pos :: distinct[2]int
Board :: distinct map[Pos]int

main :: proc () {
  s := strings.split(strings.trim_space(input), "\n\n")
  header := transmute([]u8)(s[0])
  pixmap := transmute([][]u8)strings.split(s[1], "\n")

  board := Board{}

  for line, y in &pixmap {
    for pixel, x in &line {
      if pixel == '#' {board[{x,y}] = 1}
    }
  }

  part1(board, header)
}

part1 :: proc (b: Board, header: []u8) {
  b := b
  offsets :: []Pos{
    {-1, -1}, {0, -1}, {1, -1}, 
    {-1,  0}, {0,  0}, {1,  0}, 
    {-1,  1}, {0,  1}, {1,  1},
  }

  when ODIN_DEBUG || true {
    min_x, min_y := 0, 0
    max_x, max_y := 0, 0
    for p in b {
      min_x = min(min_x, p.x)
      min_y = min(min_y, p.y)

      max_x = max(max_x, p.x)
      max_y = max(max_y, p.y)
    }
    fmt.println("bounds: ",min_x, min_y, ":", max_x, max_y)

    buf := make([]u8, (max_x - min_x + 1) * (max_y - min_y + 1))
    defer delete(buf)
    for p in &buf {p = '.'}

    for p in b {
      buf[(p.y - min_y) * (max_x - min_x + 1) + (p.x - min_x)] = '#'
    }

    for i in 0..(max_y - min_y) {
      fmt.println(transmute(string)buf[i * (max_x - min_x + 1): (i + 1) * (max_x - min_x + 1)])
    }
  }

  for i in 1..2 {
    new_board := Board{}

    for p in b {
      for off in offsets {
        if p + off not_in new_board {
          total := 0
          for off2 in offsets { total = total * 2 + b[p + off + off2] } 
          if header[total] == '#' {new_board[p + off] = 1}
        }
      }
    }


    b = new_board

    when ODIN_DEBUG || true {
      min_x, min_y := 0, 0
      max_x, max_y := 0, 0
      for p in b {
        min_x = min(min_x, p.x)
        min_y = min(min_y, p.y)

        max_x = max(max_x, p.x)
        max_y = max(max_y, p.y)
      }
      fmt.println("bounds: ",min_x, min_y, ":", max_x, max_y)

      buf := make([]u8, (max_x - min_x + 1) * (max_y - min_y + 1))
      defer delete(buf)
      for p in &buf {p = '.'}

      for p in b {
        buf[(p.y - min_y) * (max_x - min_x + 1) + (p.x - min_x)] = '#'
      }

      for i in 0..(max_y - min_y) {
        fmt.println(transmute(string)buf[i * (max_x - min_x + 1): (i + 1) * (max_x - min_x + 1)])
      }
    }
  }

  fmt.println(len(b))
}

when ODIN_DEBUG {
  input :: `..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###`
} else {
  input :: string(#load("20.txt"))
}

