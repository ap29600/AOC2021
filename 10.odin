package aoc10

import "core:fmt"
import "core:strings"
import "core:slice"

testing :: false 

when testing {
  input := `[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]`
} else {
  input := string(#load("10.txt"))
}


syntax_points := map[u8]int { ')' = 3, ']' = 57, '}' = 1197, '>' = 25137 }

comp_points := map[u8]int { ')' = 1, ']' = 2, '}' = 3, '>' = 4 }

inv := map[u8]u8 {
  ')' = '(', '(' = ')',
  ']' = '[', '[' = ']',
  '}' = '{', '{' = '}',
  '>' = '<', '<' = '>',
}

solve :: proc (lines: [][]u8) {
  syntax_error_score := 0
  comp_scores := [dynamic]int{}
  defer delete(comp_scores)
  contexts := [dynamic]u8{}
  defer delete(contexts)

  outer: for line in lines {
    defer clear(&contexts)
    for c in line {
      switch (c) {
        case '(', '[', '{', '<':
          append(&contexts, c)
        case ')', ']', '}', '>':
          if contexts[len(contexts) - 1] == inv[c] {
            pop(&contexts)
          } else {
            syntax_error_score += syntax_points[c]
            continue outer
          }
      }
    }

    comp_score := 0
    for i in 1..len(contexts) {
      comp_score = comp_score * 5 + comp_points[inv[contexts[len(contexts) - i]]]
    }
    append(&comp_scores, comp_score)
  }
  fmt.println("Part1:", syntax_error_score)
  slice.sort(comp_scores[:])
  fmt.println("Part2:", comp_scores[len(comp_scores) / 2])
}

main :: proc () {
  lines := transmute([][]u8)strings.split(strings.trim_space(input), "\n")
  solve(lines)
}
