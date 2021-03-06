package aoc21

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:strconv"
import "core:testing"

when ODIN_DEBUG {
  input :: `Player 1 starting position: 4
Player 2 starting position: 8`
} else {
  input :: `Player 1 starting position: 5
Player 2 starting position: 9`
}

main :: proc () {
  lines := strings.split(input, "\n")

  players := [2]int{}
  players[0], _ = strconv.parse_int(lines[0][28:])
  players[1], _ = strconv.parse_int(lines[1][28:])
  players -= {1,1} // 0-index

  deterministic_die(players)
  quantum_die(players)
}

deterministic_die :: proc (players:[2]int) {
  roll :: proc (die: ^int) -> (int, bool) {
    defer die^ = (die^ + 3) % 100
    return 3 + die^ + (die^ + 1) % 100 + (die^ + 2) % 100, true
  }
  die := 0
  scores := [2]int{}
  players := players

  i := 0
  for r in roll(&die) {
    players[i%2] = (players[i%2] + r) % 10
    scores[i%2] += players[i%2] + 1
    if scores[i%2] >= 1000 do break
    i += 1
  }
  fmt.println("Part1:", scores[(i+1)%2] * (i + 1) * 3)
}

p1_mul :: 10 * 21 * 21
p2_mul :: 21 * 21
s1_mul :: 21
s2_mul :: 1

to_id :: proc (p, s: [2]int) -> int {
   return p[0] * p1_mul + 
          p[1] * p2_mul +
          s[0] * s1_mul +
          s[1] * s2_mul 
}

from_id :: proc (id: int) -> (p, s: [2]int) {
  p = {(id / p1_mul) % 10, (id / p2_mul) % 10}
  s = {(id / s1_mul) % 21, (id / s2_mul) % 21}
  return p, s
}

@test
test_id :: proc (t: ^testing.T) {
  p, s := [2]int{1, 2}, [2]int{3, 4}
  p_, s_ := from_id(to_id(p, s))
  testing.expect_value(t, p_, p)
  testing.expect_value(t, s_, s)
}

quantum_die :: proc (players: [2]int) {

  game_states := map[int]int{to_id(players, {}) = 1}; defer delete(game_states)
  new_states := map[int]int{}; defer delete(new_states)

  wins := [2]int{}
  for i := 0; len(game_states) > 0; i += 1 {
    for key in game_states {
      g := game_states[key]

      roll_counts := [?]int{ 0, 0, 0, 1, 3, 6, 7, 6, 3, 1 }
      for roll in 3..9 {
        players, scores := from_id(key)

        players[i%2] = (players[i%2] + roll) % 10
        scores[i%2] += players[i%2] + 1

        if scores[i%2] >= 21 {
          wins[i%2] += g * roll_counts[roll]
        } else {
          new_states[to_id(players, scores)] += g * roll_counts[roll]
        }
      }
    }
    game_states, new_states = new_states, game_states
    clear(&new_states)
  }

  fmt.println("Part2:", max(wins[0], wins[1]))
}

