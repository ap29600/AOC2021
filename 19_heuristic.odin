package aoc19heuristic

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:testing"

Vec :: distinct[3]int
Scanner :: struct {
  beacons: []Vec,
  dists_spec: []map[int]bool,
  dists: map[int]bool,
  pos: Vec,
  mat: matrix[3, 3]int,
}

intersection_full :: proc (as, bs: $V/map[$T]bool) -> V {
  @static res: V
  clear(&res)
  for a in as do if a in bs { res[a] = true }
  return res
}

any_intersection :: proc (as, bs: $V/map[$T]bool) -> bool {
  for a in as do if a in bs { return true }
  return false
}

parse_vec :: proc(l: string) -> (v: Vec) {
  for num, i in strings.split(l, ",", context.temp_allocator) {
    v[i], _ = strconv.parse_int(num)
  }
  return v
}

parse_scanner :: proc(s: string) -> (res: Scanner) {
  lines := strings.split(s, "\n", context.temp_allocator)
  return { beacons = slice.mapper(lines[1:], parse_vec) }
}

norm2 :: proc (v: Vec) -> int { return v.x*v.x + v.y*v.y + v.z*v.z }
normm :: proc (v: Vec) -> int { return abs(v.x) + abs(v.y) + abs(v.z) }


overlap :: proc (as, bs: Scanner) -> (pos: Vec, mat: ^matrix[3,3]int, ok: bool) {
  intersect := intersection_full(as.dists, bs.dists)
  if len(intersect) < 12 { return {}, {}, false } // we have all distances twice here

  @static points_a: [dynamic]int
  defer clear(&points_a)
  for i in 0..<len(as.beacons) {
    if any_intersection(as.dists_spec[i], intersect) { append(&points_a, i) }
  }

  @static points_b: [dynamic]int
  defer clear(&points_b)
  for i in 0..<len(bs.beacons) { if any_intersection(bs.dists_spec[i], intersect) { append(&points_b, i) }
  }
  
  for mat in &matrices {
    @static pos_count: map[Vec]int
    clear(&pos_count)

    for a in &points_a {
      for b in &points_b {
        pos := as.beacons[a] - (mat * bs.beacons[b])
        if pos_count[pos] >= 2 { return pos, &mat, true }
        pos_count[pos] += 1    
      }
    }
  }
  return {}, {}, false
}

main :: proc () {
  scanners := slice.mapper(
    strings.split(strings.trim_space(input), "\n\n", context.temp_allocator),
    parse_scanner)

  free_all(context.temp_allocator)

  for scan in &scanners {
    l := len(scan.beacons)
    scan.dists = make(map[int]bool, (l*l)/2)
    scan.dists_spec = make([]map[int]bool, l)
    for a, i in &scan.beacons {
      for b, j in &scan.beacons { 
        if j == i do break
        n := norm2(b-a)
        scan.dists_spec[i][n] = true
        scan.dists_spec[j][n] = true
        scan.dists[n] = true
      }
    }
  }

  scanners[0].mat = matrices[0] // identity
  points := map[Vec]bool{}

  for boundary := 1; boundary < len(scanners); {
    for known := 0; known < boundary; known += 1 {
      for scan := boundary; scan < len(scanners); scan += 1 {
        if pos, mat, ok := overlap(scanners[known], scanners[scan]); ok {
          scanners[scan].mat = scanners[known].mat * mat^
          scanners[scan].pos = scanners[known].pos + scanners[known].mat * pos
          slice.swap(scanners, scan, boundary)
          boundary += 1
        }
      }
    }
  }

  max_dist := 0
  for scan, i in &scanners {
    for b in &scan.beacons {
      points[scan.pos + scan.mat * b] = true
    }
    for other, j in &scanners {
      if i == j do break
      max_dist = max(max_dist, normm(scan.pos - other.pos))
    }
  }

  fmt.println("Part1:", len(points))
  fmt.println("Part2:", max_dist)
}

matrices := [?]matrix[3,3]int {
  { 1, 0, 0, 0, 1, 0, 0, 0, 1},
  { 1, 0, 0, 0,-1, 0, 0, 0,-1},
  {-1, 0, 0, 0, 1, 0, 0, 0,-1},
  {-1, 0, 0, 0,-1, 0, 0, 0, 1},

  { 0, 1, 0, 1, 0, 0, 0, 0,-1},
  { 0, 1, 0,-1, 0, 0, 0, 0, 1},
  { 0,-1, 0, 1, 0, 0, 0, 0, 1},
  { 0,-1, 0,-1, 0, 0, 0, 0,-1},

  { 1, 0, 0, 0, 0, 1, 0,-1, 0},
  { 1, 0, 0, 0, 0,-1, 0, 1, 0},
  {-1, 0, 0, 0, 0, 1, 0, 1, 0},
  {-1, 0, 0, 0, 0,-1, 0,-1, 0},

  { 0, 0, 1, 1, 0, 0, 0, 1, 0},
  { 0, 0, 1,-1, 0, 0, 0,-1, 0},
  { 0, 0,-1, 1, 0, 0, 0,-1, 0},
  { 0, 0,-1,-1, 0, 0, 0, 1, 0},

  { 0, 0, 1, 0, 1, 0,-1, 0, 0},
  { 0, 0, 1, 0,-1, 0, 1, 0, 0},
  { 0, 0,-1, 0, 1, 0, 1, 0, 0},
  { 0, 0,-1, 0,-1, 0,-1, 0, 0},

  { 0, 1, 0, 0, 0, 1, 1, 0, 0},
  { 0, 1, 0, 0, 0,-1,-1, 0, 0},
  { 0,-1, 0, 0, 0, 1,-1, 0, 0},
  { 0,-1, 0, 0, 0,-1, 1, 0, 0},
}

@test
check_matrices :: proc (t: ^testing.T) {
  for a, i in matrices {
    testing.expect(t,determinant(a) == 1)
    for b, j in matrices {
      if i == j do break
      testing.expect(t, a != b)
      fmt.println(i, j, slice.linear_search(matrices[:], a * b))
    }
  }
}

input :: string(#load("19.txt"))
