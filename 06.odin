package aoc06

import "core:fmt"
import "core:strconv"
import "core:strings"

testing :: false

when testing { input :: "3,4,3,1,2" } 
else { input :: string(#load("06.txt")) }

FishPool :: distinct[9]u64

make_fishpool :: proc (s: string) -> FishPool {
  fishes := strings.split(s, ",")
  defer delete(fishes)
  pool := FishPool{}
  for f in fishes { 
    age, _ := strconv.parse_int(f)
    pool[age] += 1
  }
  return pool
}


solve :: proc (days: int) {
  pool := make_fishpool(input)

  for _ in 1..days {
    n := FishPool{}
    for counter in 0..7 { n[counter] = pool[counter + 1] }
    n[8] = pool[0] // each fish with a counter of 0 makes a baby fish
    if pool[0] + n[6] < n[6] { fmt.println("OVERFLOW!") }
    n[6] += pool[0] // after that, it sets its counter to 6
    pool = n
  } 
  
  count: u64 = 0
  for age in 0..8 { count += pool[age] }
  fmt.printf("Total fish after %d days: %d\n", days, count)
}

main :: proc () {
  solve( days = 80 )
  solve( days = 256 )
}
