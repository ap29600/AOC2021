package aoc15

import "core:fmt"
import "core:slice"
import "core:strings"

Heap :: struct ($T: typeid) { data: [dynamic]T }

heap_push :: proc (using h: ^Heap($T), c: T) 
  where type_of(c.score) == int #no_bounds_check {

  i, parent := len(data), (len(data) - 1) / 2
  append(&data, c)
  for parent < i && data[parent].score > data[i].score {
    data[parent], data[i] = data[i], data[parent]
    parent, i = (parent - 1) / 2, parent
  }
}

heapify :: proc (using h: ^Heap($T), i := 0) 
  where type_of(h.data[0].score) == int #no_bounds_check {

  l := i * 2 + 1
  r := i * 2 + 2

  min := i
  if l < len(data) && data[l].score < data[i].score { min = l }
  if r < len(data) && data[r].score < data[min].score { min = r }

  if min != i { 
    data[i], data[min] = data[min], data[i] 
    heapify(h, min)
  }
}

heap_pop :: proc (using h: ^Heap($T)) -> (T, bool) #no_bounds_check {
  if len(data) == 0 { return ---, false }
  result := data[0]
  data[0] = data[len(data)-1]
  pop(&data)
  heapify(h)
  return result, true
}

main :: proc () {
  board := transmute([][]u8)strings.split(strings.trim_space(input), "\n")
  solve("Part1", board)
  solve("Part2", board)
}

Cell :: struct { pos: [2]int, score: int }

solve :: proc ($P: string, risk: [][]u8) #no_bounds_check {
  when P == "Part1" {
    cell_cost :: #force_inline proc (risk: [][]u8, w, h: int, pos: [2]int) -> int  { return int(risk[pos.y][pos.x] - '0') }
    h, w := len(risk), len(risk[0])
  } else when P == "Part2" {
    h, w := len(risk) * 5, len(risk[0]) * 5
    cell_cost :: #force_inline proc (risk: [][]u8, w, h: int, pos: [2]int) -> int  {
      return ((int(risk[pos.y % (h/5)][pos.x % (w/5)] - '0') + (pos.x / (w / 5)) + (pos.y / (h / 5)) - 1) % 9) + 1
    }
  } else {
    fmt.println("invalid polymorphic parameter", P, "for solve")
    if true do return
    w, h: int
    cell_cost :: proc (risk: [][]u8, w, h: int, pos: [2]int) -> int {return 0}
  }

  board := Heap(Cell){data = {Cell{}}}
  reserve(&board.data, w*h)
  defer delete(board.data)

  visited := make([]b8, w*h)
  defer delete(visited)

  for len(board.data) > 0 {
    u, _ := heap_pop(&board)
    if visited[u.pos.y * w + u.pos.x] do continue
    visited[u.pos.y * w + u.pos.x] = true

    if u.pos == {w-1, h-1} { fmt.println(P, u.score); return }

    offsets :: [4][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
    for off in offsets {
      p := u.pos + off
      if p.x < 0 || p.x >= w || p.y < 0 || p.y >= h do continue
      if !visited[p.y * w + p.x] {
        heap_push(&board, Cell{p, u.score + cell_cost(risk, w, h, p)})
      }
    }
  }
}

when ODIN_DEBUG {
  input :: `1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
`
} else {
  input :: string(#load("15.txt"))
}
