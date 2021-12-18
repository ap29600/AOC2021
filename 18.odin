package aoc18

import "core:fmt"
import "core:slice"
import "core:mem"
import "core:strings"

SnailNum :: struct {
  digits: [dynamic]int,
  depths: [dynamic]int,
}

parse_snailnum :: proc (s: string) -> (res: SnailNum) {
  depth := 0
  for c in s {
    switch (c) {
      case '0'..'9':
        append(&res.digits, int(c) - '0')
        append(&res.depths, depth)
      case '[':
        append(&res.digits, -1)
        append(&res.depths, depth)
        depth += 1;   
      case ']':
        depth -= 1;
      case:
    }
  }
  return res
}

add :: proc (a, b: SnailNum) -> SnailNum {
  res := SnailNum { 
    [dynamic]int{-1},
    [dynamic]int{0},
  }
  for i in 0..<len(a.digits) {
    append(&res.digits, a.digits[i])
    append(&res.depths, a.depths[i] + 1)
  }
  for i in 0..<len(b.digits) {
    append(&res.digits, b.digits[i])
    append(&res.depths, b.depths[i] + 1)
  }
  reduce(&res)
  return res
}

print_snail_number :: proc (n: SnailNum) {
  for i in 0..<len(n.digits) {
    if i > 0 do for _ in n.depths[i]..<n.depths[i-1] {
      fmt.printf("]")
    }
    switch (n.digits[i]) {
    case -1:
      fmt.printf("[")
    case :
      if n.digits[i-1] == -1 {
        fmt.printf("%d", n.digits[i])
      } else {
        fmt.printf(",%d", n.digits[i])
      }
    }
  }
  for _ in 0..<n.depths[len(n.depths) - 1] {
      fmt.printf("]")
  }
  fmt.println("")
}

reduce :: proc (e: ^SnailNum) {
  outer: for go := true; go; {
    go = false
    for i in 0..<len(e.digits) {
      if e.depths[i] > 4 {
        // explode

        // carry left
        carry_left: for j in 1..i do if e.digits[i - j] >= 0 {
          e.digits[i - j] += e.digits[i]
          break carry_left
        }

        //carry right
        carry_right: for j in 2..<len(e.digits) - i do if e.digits[i + j] >= 0 {
          e.digits[i + j] += e.digits[i + 1]
          break carry_right
        }
        
        // replace the pair with a 0
        e.digits[i - 1] = 0 


        // collapse the pair
        if i+2 < len(e.digits) {
          mem.copy(&e.digits[i], &e.digits[i+2], len(e.digits[i+2:]) * size_of(e.digits[0]))
          mem.copy(&e.depths[i], &e.depths[i+2], len(e.depths[i+2:]) * size_of(e.depths[0]))
        }
        resize(&e.digits, len(e.digits) - 2)
        resize(&e.depths, len(e.depths) - 2)

        go = true
        continue outer
      }
    }

    for i in 0..<len(e.digits) {
      if e.digits[i] > 9 {
        // split
        val := e.digits[i]

        // insert a new pair
        e.digits[i] = -1

        // expand the pair
        resize(&e.digits, len(e.digits) + 2)
        resize(&e.depths, len(e.depths) + 2)
        if (len(e.digits) > i + 3) {
          mem.copy(&e.digits[i+3], &e.digits[i+1], len(e.digits[i+3:])*size_of(e.digits[0]))
          mem.copy(&e.depths[i+3], &e.depths[i+1], len(e.depths[i+3:])*size_of(e.depths[0]))
        }

        e.digits[i+1] = val/2
        e.digits[i+2] = (val+1) / 2

        e.depths[i+1] = e.depths[i] + 1
        e.depths[i+2] = e.depths[i] + 1

        go = true
        continue outer
      }
    }
  }
}

magnitude :: proc (e: SnailNum) -> int {
  go :: proc (digits: []int, depths: []int, start_depth: int) -> int {
    if digits[0] >= 0 { return digits[0] }

    for d, i in depths[2:] {
      if d == start_depth + 1 {
        left := go(digits[1:i+2], depths[1:i+2], start_depth + 1)
        right := go(digits[i+2:], depths[i+2:], start_depth + 1)
        return 3 * left + 2 * right
      }
    }

    fmt.println("malformed expression")
    return -1
  }

  return go(e.digits[:], e.depths[:], 0)
}

to_string :: proc (e: SnailNum) -> string {
  return fmt.tprintf("{{ {} \n  {} }} ", e.digits, e.depths)
}

main :: proc () {
  numbers := slice.mapper(strings.split(strings.trim_space(input), "\n"), parse_snailnum)
  total := numbers[0]
  for other, i in numbers[1:] { 
    res := add(total, other)
    if i > 0 {delete(total.digits); delete(total.depths)}
    total = res
  }
  fmt.println("Part1:", magnitude(total))

  max_magnitude := 0
  for n, i in numbers {
    for m, j in numbers {
      if i != j {
        sum := add(n, m)
        max_magnitude = max(max_magnitude, magnitude(sum))
        delete(sum.digits)
        delete(sum.depths)
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
