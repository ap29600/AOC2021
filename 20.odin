package aoc20

import "core:fmt"
import "core:slice"
import "core:strings"

Pos :: distinct[2]int

main :: proc () {
  s := strings.split(strings.trim_space(input), "\n\n")
  header := transmute([]u8)(s[0])
  pixmap := transmute([][]u8)strings.split(s[1], "\n")

  part1(pixmap, header)
}

in_bounds :: proc (p, l, h: Pos) -> bool {
  return max((h.x - p.x)*(l.x - p.x), 
             (h.y - p.y)*(l.y - p.y)) <= 0
} 

part1 :: proc (board: [][]u8, header: []u8) {
  board := board
  offsets :: []Pos{
    {-1, -1}, {0, -1}, {1, -1}, 
    {-1,  0}, {0,  0}, {1,  0}, 
    {-1,  1}, {0,  1}, {1,  1},
  }
  low, high := Pos{0, 0}, Pos{len(board[0]) - 1, len(board) - 1}

  for i in 0..49 {
    
    new_board := make([][]u8, len(board) + 2, context.temp_allocator)
    for y in low.y-1..high.y+1 {
      new_line := make([]u8, len(board[0]) + 2, context.temp_allocator)
      new_board[y - low.y + 1] = new_line
      for x in low.x-1..high.x+1 {
        index := 0
        for off in offsets {
          p := off + {x, y}
          bit := int(board[p.y - low.y][p.x - low.x] == '#') if 
                 in_bounds(p, low, high) else ((i%2) * int(header[0] == '#'))
          index = index * 2 + bit
        }
        new_line[x - low.x + 1] = header[index]
      }
    }

    board = new_board

    low -= {1, 1}
    high += {1, 1}
    if i == 1 || i == 49 {
      count := 0
      for line in board do for cell in line { if cell == '#' { count += 1 } }
      fmt.println("At step", i, ":" ,count)
    }
  }

  free_all(context.temp_allocator)
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

