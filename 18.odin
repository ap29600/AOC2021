package aoc18

import "core:fmt"
import "core:slice"
import "core:mem"
import "core:strings"
import "core:intrinsics"


SnailDigit :: struct {
  value: int,
  depth: int,
}
SnailNum :: [dynamic] SnailDigit

parse_snailnum :: proc (s: string) -> (res: SnailNum) {
  depth := 0
  for c in s {
    switch (c) {
      case '0'..'9':
        append(&res, SnailDigit{int(c) - '0', depth})
      case '[':
        append(&res, SnailDigit{-1, depth})
        depth += 1;   
      case ']':
        depth -= 1;
      case:
    }
  }
  return res
}

add :: proc (a, b: SnailNum) -> SnailNum #no_bounds_check {
  res := SnailNum { {-1, -1} }

  resize(&res, len(a) + len(b) + 1)

  off := len(a) + 1
  mem.copy(&res[1], &a[0], len(a) * size_of(a[0]))
  mem.copy(&res[off], &b[0], len(b) * size_of(b[0]))
  for d in &res {d.depth += 1}

  reduce(&res)
  return res
}

add_in_place :: proc (a: ^SnailNum, b: SnailNum) {
  insert_at_elem(a, 0, SnailDigit{-1, -1})
  off := len(a)
  resize(a, len(a) + len(b))
  mem.copy(&a[off], &b[0], len(b) * size_of(b[0]))
  for d in a {d.depth += 1}

  reduce(a)
}

print_snail_number :: proc (n: SnailNum) {
  fmt.printf("[")
  for i in 1..<len(n) {
    for _ in n[i].depth..<n[i-1].depth { fmt.printf("]") }

    switch (n[i].value) {
      case -1: fmt.printf("[")
      case :
        if n[i-1].value == -1 {
          fmt.printf("%d", n[i].value)
        } else {
          fmt.printf(",%d", n[i].value)
        }
    }
  }
  for _ in 0..<n[len(n) - 1].depth {
      fmt.printf("]")
  }
  fmt.println("")
}

reduce :: proc (e: ^SnailNum) #no_bounds_check {
  outer: for {
    // explode
    for i in 0..<len(e) {
      if e[i].depth > 4 {

        // carry left and right
        for j in 1..i do if e[i - j].value >= 0 {
          e[i - j].value += e[i].value
          break 
        }
        for j in 2..<len(e) - i do if e[i + j].value >= 0 {
          e[i + j].value += e[i + 1].value
          break 
        }
        
        // replace the pair with a 0
        e[i - 1].value = 0 
        remove_range(e, i, i+2)

        continue outer
      }
    }

    // split
    for i in 0..<len(e) {
      if e[i].value > 9 {
        value, depth := e[i].value, e[i].depth

        e[i].value = -1
        insert_at_elems(e, i+1, SnailDigit{value / 2, depth + 1}, SnailDigit{(value + 1) / 2, depth + 1})

        continue outer
      }
    }
    return
  }
}

magnitude :: proc (e: SnailNum) -> int {
  go :: proc (e: []SnailDigit, start_depth: int) -> int #no_bounds_check {
    if e[0].value >= 0 { return e[0].value }

    for d, i in e[2:] {
      if d.depth == start_depth + 1 {
        left := go(e[1:i+2], start_depth + 1)
        right := go(e[i+2:], start_depth + 1)
        return 3 * left + 2 * right
      }
    }

    fmt.println("malformed expression")
    return -1
  }

  return go(e[:], 0)
}


main :: proc () {
  numbers := slice.mapper(strings.split(strings.trim_space(input), "\n"), parse_snailnum)
  total := numbers[0]
  for other in numbers[2:] { 
    res := add(total, other) 
    total = res
  }
  fmt.println("Part1:", magnitude(total))

  // sum := SnailNum{}
  max_magnitude := 0
  for n, i in numbers {
    for m, j in numbers {
      if i != j {

        sum := add(n, m)
        max_magnitude = max(max_magnitude, magnitude(sum))
        delete(sum)
      }
    }
  }
  fmt.println("Part2:", max_magnitude)
}

when ODIN_DEBUG {
  input :: `[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
`

} else {
  input :: string(#load("18.txt"))
}
