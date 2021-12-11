package aoc2021

import "core:fmt"
import "core:slice"
import "core:strings"

testing :: false
when testing {
  input :: `2199943210
3987894921
9856789892
8767896789
9899965678
`
} else {
  input :: string(#load("09.txt"))
}

part1 :: proc(hs:[][]u8) {
  w, h :=  len(hs[0]), len(hs)
  score := 0
  for row, i in hs {
    for ht, j in row {
      if (i != 0 && ht >= hs[i-1][j]) || (i != h-1 && ht >= hs[i+1][j]) ||
         (j != 0 && ht >= hs[i][j-1]) || (j != w-1 && ht >= hs[i][j+1]) {
        continue
      }
      score += 1 + int(ht) - '0'
    }
  }
  fmt.println("Part1: ", score)
}

Basin :: struct {
  interfaces: [dynamic][2]int,
  tmp_interfaces: [dynamic][2]int,
  size: int,
}

merge :: proc (a, b: ^Basin) {
  defer delete(b.interfaces)
  defer delete(b.tmp_interfaces)
  for itf in &b.interfaces { append(&a.interfaces, itf) }
  for itf in &b.tmp_interfaces { append(&a.tmp_interfaces, itf) }
  a.size += b.size
}

overlap :: proc (a, b: [2]int) -> bool {
  res := (a.y > a.x) && (b.y > b.x) &&  // none of the segments are empty
         (b.x < a.y) && (a.x < b.y)   // they overlap
  return res
}

remove :: proc (a: ^[dynamic]Basin, i: int) {
  if i < len(a) {
    a[i], a[len(a) - 1] = a[len(a) - 1], a[i]
    pop(a)
  }
}

insert_in_basin :: proc (start, end: int, basins: ^[dynamic]Basin) {
  if end < start {fmt.println("ERROR: end is", end, "start is", start)}
  if end == start {return}
  found: ^Basin = nil
  merge_basins: for b := 0; b < len(basins); b += 1 {
    for itf in &basins[b].interfaces {
      if overlap({start, end}, itf) {
        if found == nil {
          found = &basins[b]
          found.size += end - start
          append(&found.tmp_interfaces, [2]int{start, end})
        } else { 
          merge(found, &basins[b])
          remove(basins, b)
          b -= 1 // this position will be filled by another basin
        }
        continue merge_basins 
      }
    }
  }
  if found == nil && end > start {
    b := Basin{tmp_interfaces = {{start, end}}, size = end - start}
    append(basins, b)
  }
}

basin_size :: proc (b: Basin) -> int {
  return b.size
}

// since basins have to be unambiguous, they are always
// separated by barriers of 9, otherwise the digit that separates
// two basins could be interpreted as being part of either one.
part2 :: proc (hs: [][]u8) {
  basins := [dynamic]Basin{}
  for row in hs {
    start := 0 // the start of a patch
    for c, end in row {
      if c == '9' { // at the boundary
        insert_in_basin(start, end, &basins)
        start = end + 1
      }
    }
    insert_in_basin(start, len(row), &basins)
    for b in &basins {
      delete(b.interfaces)
      b.interfaces = b.tmp_interfaces
      b.tmp_interfaces = {}
    }
  }
  sizes := slice.mapper(basins[:], basin_size)
  slice.reverse_sort(sizes)
  fmt.println("Biggest basins:", sizes[0:3], "Result: ", sizes[0] * sizes[1] * sizes[2])
}

main :: proc () {
  lines := strings.split(strings.trim_space(input), "\n")
  height_map := transmute([][]u8)lines
  
  part1(height_map)
  part2(height_map)
}
