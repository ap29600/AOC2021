package aoc22

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"

Range :: distinct [2]int

Region :: struct {
  using ranges: [3]Range,
  state: bool,
}

intersect :: proc (a, b: Region) -> bool {
  return a.x[0] < b.x[1] && a.x[1] > b.x[0] &&
         a.y[0] < b.y[1] && a.y[1] > b.y[0] &&
         a.z[0] < b.z[1] && a.z[1] > b.z[0]
}

fully_contained :: proc (a, b: Region) -> bool {
  return a.x[0] >= b.x[0] && a.x[1] <= b.x[1] &&
         a.y[0] >= b.y[0] && a.y[1] <= b.y[1] &&
         a.z[0] >= b.z[0] && a.z[1] <= b.z[1]
}

area :: proc (a: Region) -> int {
  return (a.x[1] - a.x[0]) * (a.y[1] - a.y[0]) * (a.z[1] - a.z[0])
}

Kind :: enum {
  None,
  Split,
  Glob,
}

split :: proc (a, b: Region) ->([dynamic]Region, Kind) {

  if !intersect(a, b) do return {}, .None

  // a.state is always true: in this case the command to turn
  // on some voxels has no effect, so we consume it.
  if b.state && fully_contained(b, a) do return {}, .Glob

  // b completely overwrites a: we state that a has been
  // split in exactly 0 parts.
  if fully_contained(a, b) do return {}, .Split

  // begin splitting
  xs := [4]int{a.x[0], a.x[1], b.x[0], b.x[1]}
  ys := [4]int{a.y[0], a.y[1], b.y[0], b.y[1]}
  zs := [4]int{a.z[0], a.z[1], b.z[0], b.z[1]}

  slice.sort(xs[:])
  slice.sort(ys[:])
  slice.sort(zs[:])

  // temporary allocator is a ring-buffer, it's fine to
  // return this array and leak it later
  result := make([dynamic]Region, context.temp_allocator)

  for i in 0..2 do if xs[i] < xs[i+1] {
    for j in 0..2 do if ys[j] < ys[j+1] {
      for k in 0..2 do if zs[k] < zs[k+1] {
        new_region := Region{{{xs[i], xs[i+1]}, {ys[j], ys[j+1]}, {zs[k], zs[k+1]}}, true}
        if intersect(new_region, a) && !intersect(new_region, b) {
          append(&result, new_region)
        }
      }
    }
  }
  return result, .Split
}

parse_region :: proc (s: string) -> (res: Region) {
  splits := strings.split(s, " ", context.temp_allocator)
  if splits[0] == "on" {res.state = true}

  ranges := strings.split(splits[1], ",", context.temp_allocator)
  for range, i in ranges {
    lims := strings.split(range[2:], "..", context.temp_allocator)
    res.ranges[i][0], _ = strconv.parse_int(lims[0])
    res.ranges[i][1], _ = strconv.parse_int(lims[1])
    res.ranges[i][1] += 1 
    // the logic is a lot better if the intervals are open to the right: [min, max] becomes [min, max + 1)
  }
  return res
}

main :: proc() {
  commands := slice.mapper(
    strings.split(
      strings.trim_space(input), "\n",
      context.temp_allocator),
    parse_region)

  regions := [dynamic]Region{}
  defer delete(regions)

  cmds: for command in commands {
    for i := 0; i < len(regions); i += 1 {
      parts, kind := split(regions[i], command)
      switch kind {
        case .Glob:
          // the command ended up having no effect due to turning on
          // an area which was already on.
          continue cmds
        case .Split:
          // the command partially overlapped with a region.
          // we add the splits to the list of regions
          for part in parts {append(&regions, part)}
          unordered_remove(&regions, i)
          i -= 1
        case .None:
          // there was no overlap
      }
    }
    // finally add the new region. this gets skipped in the .Glob
    // case above, because the new region was redundant.
    if command.state do append(&regions, command)
  }

  // see note on open ranges in the parsing proc.
  part1_range := Range{-50, 51} 
  region1 := Region{ranges = part1_range}

  part1, part2 := 0, 0
  for region in &regions {
    part1 += area(clamp_to_region(region, region1))
    part2 += area(region)
  }
  fmt.println("Part 1:", part1)
  fmt.println("Part 2:", part2)
}

clamp_to_region :: proc (a, b: Region) -> Region {
  result := a
  // for part 1:
  for component, i in &result.ranges {
    for j in 0..1 {
      component[j] = max(min(component[j], b.ranges[i][1]), b.ranges[i][0])
    }
  }
  return result
}

when ODIN_DEBUG {
  input :: `on x=10..12,y=10..12,z=10..12
on x=11..13,y=11..13,z=11..13
off x=9..11,y=9..11,z=9..11
on x=10..10,y=10..10,z=10..10`
} else when #config(sample, false) {
  input :: `on x=-20..26,y=-36..17,z=-47..7
on x=-20..33,y=-21..23,z=-26..28
on x=-22..28,y=-29..23,z=-38..16
on x=-46..7,y=-6..46,z=-50..-1
on x=-49..1,y=-3..46,z=-24..28
on x=2..47,y=-22..22,z=-23..27
on x=-27..23,y=-28..26,z=-21..29
on x=-39..5,y=-6..47,z=-3..44
on x=-30..21,y=-8..43,z=-13..34
on x=-22..26,y=-27..20,z=-29..19
off x=-48..-32,y=26..41,z=-47..-37
on x=-12..35,y=6..50,z=-50..-2
off x=-48..-32,y=-32..-16,z=-15..-5
on x=-18..26,y=-33..15,z=-7..46
off x=-40..-22,y=-38..-28,z=23..41
on x=-16..35,y=-41..10,z=-47..6
off x=-32..-23,y=11..30,z=-14..3
on x=-49..-5,y=-3..45,z=-29..18
off x=18..30,y=-20..-8,z=-3..13
on x=-41..9,y=-7..43,z=-33..15
on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
on x=967..23432,y=45373..81175,z=27513..53682`
} else {
  input :: string(#load("22.txt"))
}
