package aoc19

import "core:fmt"
import "core:math"
import "core:mem"
import "core:slice"
import "core:strings"
import "core:strconv"

Scanner :: [dynamic]Vec
Vec :: distinct[D]int 

parse_vec :: proc (s: string) -> (res: Vec) {
  coords_raw := strings.split(s, ",", context.temp_allocator)
  for i in 0..<D { res[i], _ = strconv.parse_int(coords_raw[i]) }
  return res
}

parse_scanner :: proc (s: string) -> Scanner {
  positions := slice.mapper(strings.split(s, "\n")[1:], parse_vec, context.temp_allocator)
  return cast(Scanner)slice.to_dynamic(positions)
}

main :: proc () {
  scanners_raw := strings.split(strings.trim_space(input), "\n\n", context.temp_allocator)
  scanners := slice.mapper(scanners_raw, parse_scanner) 
  free_all(context.temp_allocator)

  part1(scanners)
}


KnownScanner :: struct {
  scan: Scanner,
  pos: Vec,
}


minimum_offset :: proc (p: Vec, a: []Vec) -> Vec {
  result: Vec
  min_d := max(int)

  for q in a {
    v := q - p
    d := norm(v)
    if d < min_d { 
      min_d = d
      result = v 
    }
  }

  return result
}


icp :: proc (a: []Vec, b: []Vec, mat: matrix[D, D]int) -> (Vec, bool) {
  b := b
  a := a
  d := [dynamic]Vec{}
  reserve(&d, overlap_num + 1)

  for initial_offset in offsets {
    total_offset := initial_offset

    for _ in 0..3 {
      clear(&d)

      for p in &b { 
        m := minimum_offset(mat * p + total_offset, a)
        append(&d, m)
        for i := len(d) - 2; i >= 0 && norm(d[i]) > norm(d[i+1]); i -= 1{
          d[i+1], d[i] = d[i], d[i+1]
        }
        if len(d) > overlap_num {pop (&d)}
      }

      pull_vector := Vec{}

      for i in 0..<overlap_num { 
        pull_vector += d[i] 
      }

      if d[overlap_num - 1] == {} { return total_offset, true }

      pull_vector /= overlap_num
      if norm(pull_vector) == 0 { break }

      total_offset += pull_vector
    }
  }
  return Vec{}, false
}

fnorm :: proc (v: Vec) -> f64 { return math.sqrt(f64(norm(v))) }


part1 :: proc (scanners: []Scanner) {
  known := [dynamic]struct{s: Scanner, p: Vec}{{scanners[0], {}}}
  scanners := scanners[1:]
  all_points := map[Vec]bool{}

  for k in &known {
    for i := 0; i < len(scanners); i += 1  {
      s := scanners[i]
      for mat in &matrices {

        if offset, ok := icp(k.s[:], s[:], mat); ok {
          //fmt.println("Offset: ", offset)

          for v in &s {v = mat*v}
          append(&known, type_of(k){s, offset + k.p})

          slice.swap(scanners, i, 0)
          scanners = scanners[1:]
          i -= 1

          break
        }
      }
    }
  }  

  for k in &known {
    for p in &k.s {
      all_points[p + k.p] = true
    }
  }

  max_dist := 0
  for k, i in &known {
    for other,j in &known {
      if i == j do break
      max_dist = max(max_dist, norm_1(k.p - other.p))
    }
  }

  fmt.println(len(all_points))
  fmt.println(max_dist)
}

when ODIN_DEBUG {
  when #config(sample, true) {
    overlap_num :: 3
    D :: 2
  } else {
    overlap_num :: 12
    D :: 3
  }
} else {
  D :: 3
}

when D == 3 {
  matrices := generate_rotation_matrices()

  generate_rotation_matrices :: proc () -> []matrix[3, 3]int {
    result := [dynamic]matrix[3, 3]int{}
    reserve(&result, 24)
    entries := [6]int{0, 1, 2, 3, 4, 5}
    for i in entries {
      for j in entries do if j%3 != i%3 {
        mat := matrix[3,3]int{}
        mat[0, i%3] = (1 if i < 3 else -1)
        mat[1, j%3] = (1 if j < 3 else -1)
        for k in entries {
          mat[2, 0] = 0
          mat[2, 1] = 0
          mat[2, 2] = 0

          mat[2, k%3] = (1 if k < 3 else -1)
          if determinant(mat) == 1 {
            append(&result, mat)
            break
          }
        }
      }
    }
    if len(result) != 24 {
      fmt.println("ERROR: got", len(result), "matrices, expected 24")
      return {}
    }
    return result[:] 
  }
} else {
  matrices := []matrix[2, 2]int{ {1, 0, 0, 1}, {-1, 0, 0, -1}, {0, 1, -1, 0}, {0, -1, 1, 0} }
}

when D == 2 {
  norm :: proc(v: Vec) -> int { return (v.x * v.x) + (v.y * v.y) }
  norm_i :: proc(v: Vec) -> int { return max(abs(v.x) + abs(v.y)) }
  norm_1 :: proc(v: Vec) -> int { return abs(v.x) + abs(v.y)}
} else {
  norm :: proc(v: Vec) -> int { return (v.x * v.x) + (v.y * v.y) + (v.z * v.z) }
  norm_i :: proc(v: Vec) -> int { return max(abs(v.x), abs(v.y), abs(v.z)) }
  norm_1 :: proc(v: Vec) -> int { return abs(v.x) + abs(v.y) + abs(v.z) }
}

when D == 2 {
  offsets := []Vec{
    {-1000, 0}, {0, -1000},
    { 1000, 0}, {0,  1000},
  }
} else {
  offsets := []Vec{
    {-1000, 0, 0}, {0, -1000, 0},{0, 0, -1000},
    { 1000, 0, 0}, {0,  1000, 0},{0, 0,  1000},
  }
}


when ODIN_DEBUG {
  when #config(sample, true) {
    input :: `--- scanner 0 ---
0,2
4,1
3,3

--- scanner 1 ---
-1,-1
-5,0
-2,1`
  } else {
    input :: `--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14`
  }
} else {
  overlap_num := 12
  input :: string(#load("19.txt"))
}
