package aoc07

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:slice"

testing :: false

when testing {
  input := `16,1,2,0,4,2,7,1,2,14`
} else {
  input := string(#load("07.txt"))
}

main :: proc () {
  positions := [dynamic]int{}
  defer delete(positions)

  for s in strings.split(input, ",") {
    n, _:= strconv.parse_int(s)
    append(&positions, n)
  }
  slice.sort(positions[:])
  part1(positions[:])
  part2(positions[:])
}


// since the cost of moving is linear, consider the crabs as being aligned on
// a line: if there are more crabs on the left, then moving the target left  
// saves one step for every crab on that side, at the cost of one step for
// every crab on the other. Considering this, the optimal solution is reached
// when there is the same number of crabs on each side, and the target is
// directly on a crab.
part1 :: proc (positions: []int) {
  median := positions[len(positions)/2]
  total_dist := 0
  for pos in positions {
    total_dist += abs(pos - median)
  }
  fmt.printf("best cost for part 1: %d at position %d\n", total_dist, median)
}

// when the cost of moving increases for every step, the closed-form solution
// for the cost is (d + 1) * d / 2, which is roughly quadratic in d.
// The position which minimizes square distance in a set of points is the mean,
// so we get the mean and try jumping left and right a bit to account for 
// the fact that this is an estimate.
part2 :: proc (positions: []int) {
  mean := 0
  for p in positions { mean += p }
  mean /= len(positions)
  best_cost := -1
  best_pos: int
  for offset in -5..5 {
    cost := 0
    for pos in positions { 
      dist := abs(pos - (mean + offset))
      cost += dist * (dist + 1) / 2 
    }
    if best_cost == -1 || cost < best_cost {
      best_cost = cost
      best_pos = mean + offset 
    }
  }
  fmt.printf("best cost for part 2: %d at position %d\n", best_cost, best_pos)
}
