package aoc15

import "core:fmt"
import "core:slice"
import "core:strings"

Heap :: struct {
  data: [dynamic]Cell,
  cache: map[[2]int]int,
  score: proc(Cell) -> int,
}

heap_comb :: proc (using h: ^Heap, i: int) #no_bounds_check {
  i, parent := i, (i - 1) / 2
  for parent < i && score(data[parent]) > score(data[i]) {
    data[parent], data[i] = data[i], data[parent]
    cache[data[parent].pos], cache[data[i].pos] = parent, i
    parent, i = (parent - 1) / 2, parent
  }
}

heap_find :: proc (using h: ^Heap, p: [2]int, i := 0) -> (int, bool) {
  if p in cache { return cache[p], true }
  return -1, false
}

heapify :: proc (using h: ^Heap, i := 0) #no_bounds_check {
  l := i * 2 + 1
  r := i * 2 + 2

  min := i
  if l < len(data) && score(data[l]) < score(data[i]) { min = l }
  if r < len(data) && score(data[r]) < score(data[min]) { min = r }

  if min != i { 
    data[i], data[min] = data[min], data[i] 
    cache[data[i].pos], cache[data[min].pos] = i, min
    heapify(h, min)
  }
}

heap_pop :: proc (using h: ^Heap) -> (Cell, bool) #no_bounds_check {
  if len(data) == 0 { return ---, false }
  result := data[0]
  data[0] = data[len(data)-1]
  cache[data[0].pos] = 0
  pop(&data)
  delete_key(&cache, result.pos)
  heapify(h)
  return result, true
}

main :: proc () {
  board := transmute([][]u8)strings.split(strings.trim_space(input), "\n")
  part1(board)
  part2(board)
}


Cell :: struct { pos: [2]int, dist: int }

part1 :: proc (risk: [][]u8) #no_bounds_check {
  cell_cost :: #force_inline proc (risk: [][]u8, w, h: int, pos: [2]int) -> int  {
    return int(risk[pos.y][pos.x] - '0')
  }

  h, w := len(risk), len(risk[0])

  board := Heap{ data = {}, score = proc (c: Cell) -> int {return c.dist} }
  reserve(&board.data, w*h)  // cells
  defer delete(board.data)

  for i in 0..<w*h {
    append(&board.data, Cell{{i%w, i/w}, max(int)})
    board.cache[board.data[i].pos] = i
  }
  board.data[board.cache[{0, 0}]].dist = 0

  heapify(&board)

  for len(board.data) > 0 {
    u, _ := heap_pop(&board)
    if u.pos == {w-1, h-1} {
      fmt.println("Part1:", u.dist)
      return
    }

    offsets := [4][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
    for off in offsets {
      p := u.pos + off
      if p.x < 0 || p.x >= w || p.y < 0 || p.y >= h {continue} 
      cost := cell_cost(risk, w, h, p) 
      if index, ok := heap_find(&board, p); ok {
        if board.data[index].dist > u.dist + cost {
          board.data[index].dist = u.dist + cost
          heap_comb(&board, index)
        }
      }
    }
  }
}

part2 :: proc (risk: [][]u8) #no_bounds_check {
  h, w := len(risk) * 5, len(risk[0]) * 5

  cell_cost :: #force_inline proc (risk: [][]u8, w, h: int, pos: [2]int) -> int  {
    return ((int(risk[pos.y % (h/5)][pos.x % (w/5)] - '0') + (pos.x / (w / 5)) + (pos.y / (h / 5)) - 1) % 9) + 1
  }

  board := Heap{ data = {}, score = proc (c: Cell) -> int {return c.dist} }
  reserve(&board.data, w*h)  // cells
  defer delete(board.data)

  for i in 0..<w*h {
    append(&board.data, Cell{{i%w, i/w}, max(int)})
    board.cache[board.data[i].pos] = i
  }
  board.data[board.cache[{0, 0}]].dist = 0

  heapify(&board)

  for len(board.data) > 0 {
    u, _ := heap_pop(&board)
    if u.pos == {w-1, h-1} {
      fmt.println("Part2:", u.dist)
      return
    }

    offsets := [4][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
    for off in offsets {
      p := u.pos + off
      if p.x < 0 || p.x >= w || p.y < 0 || p.y >= h {continue} 
      cost := cell_cost(risk, w, h, p) 
      if index, ok := heap_find(&board, p); ok {
        if board.data[index].dist > u.dist + cost {
          board.data[index].dist = u.dist + cost
          heap_comb(&board, index)
        }
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
