package aoc17

import "core:fmt"
import "core:strings"
import "core:strconv"

when ODIN_DEBUG {
  input :: "target area: x=20..30, y=-10..-5"
} else {
  input :: string(#load("17.txt"))
}

parse_range :: proc (s: string) -> (range: [2]int) {
  splits := strings.split(s, "..")
  range[0], _ = strconv.parse_int(splits[0])
  range[1], _ = strconv.parse_int(splits[1])
  return range
}

Vec2 :: distinct [2]int
Box :: distinct [2][2]int

sign :: proc (x: int) -> int { return int(x > 0) - int(x < 0) }
step :: proc (pos, speed: Vec2) -> (new_pos, new_speed: Vec2) {
  return pos + speed, 
         speed + Vec2{ -sign(speed.x), -1 }
}

in_bounds :: proc (pos: Vec2, b: Box) -> bool {
  return max((b.x[0]-pos.x)*(b.x[1]-pos.x), 
             (b.y[0]-pos.y)*(b.y[1]-pos.y)) <= 0 
}

simulate_throw :: proc (v: Vec2, b: Box) -> (int, bool) {
  ext_box := Box{ // leaving this area means it's impossible to hit the target 
    {min(0, b.x[0]), max(0, b.x[1])},
    {min(0, b.y[0]), (v.y + 1)*v.y / 2}, // upper bound for the maximum height
  }
  max_height := 0
  pos, v := Vec2{}, v
  for ; in_bounds(pos, ext_box); pos, v = step(pos, v) {
    max_height = max(max_height, pos.y)
    if in_bounds(pos, b) do return max_height, true
  }

  return max_height, false
}

main :: proc () {
  raw_data := input[13:]
  splits := strings.split(strings.trim_space(raw_data), ", ")
  b := Box{parse_range(splits[0][2:]), parse_range(splits[1][2:])}

  hmax := 0
  count_hits := 0

  for vx in min(0, b.x[0])..max(0, b.x[1]) {
    for vy in min(0, b.y[0])..max(abs(b.y[0]), abs(b.y[1])) {
      if h, ok := simulate_throw({vx, vy}, b); ok {
        count_hits += 1
        hmax = max(hmax, h)
      }
    }
  }

  fmt.println("Part1:", hmax)
  fmt.println("Part2:", count_hits)
}
