package aoc19

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"

Scanner :: distinct[dynamic]Vec
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

part1 :: proc (scanners: []Scanner) {

  norm_i :: proc (v: Vec) -> int {
    total := 0
    for i in 0..<D { total = max(total, abs(v[i])) }
    return total
  }

  norm_1 :: proc (v: Vec) -> int {
    total := 0
    for i in 0..<D { total += abs(v[i]) }
    return total
  }

  known_scanners := [dynamic]KnownScanner{{ scanners[0], Vec{} }}
  scanners := scanners[1:]

  for len(scanners) > 0 {
    for known, known_id in &known_scanners {
      find_scanner: for scan_id := 0; scan_id < len(scanners); scan_id += 1 {
        scan := scanners[scan_id]
        for mat in matrices {
          for beacon_s in &scan {
            find_beacon: for beacon_k in &known.scan {

              off := beacon_k - mat * beacon_s

              count_k := 0 for beacon_k_tmp in &known.scan {
                if norm_i(beacon_k_tmp - off) <= 1000 { count_k += 1 }
              }
              if count_k < overlap_num { continue }

              count_s := 0
              for beacon_s_tmp in &scan {
                local_pos := off + mat * beacon_s_tmp
                if norm_i(local_pos) <= 1000 { 
                  if _, ok := slice.linear_search(known.scan[:], local_pos); ok {
                    count_s += 1 
                  } else { continue find_beacon }
                }
              }

              if count_k == count_s {
                // straighten the coordinates
                for beacon in &scan { beacon = mat * beacon }

                fmt.println("Offset:", off)

                append(&known_scanners, KnownScanner{scan, off + known.pos })
                if scan_id != 0 { slice.swap(scanners, 0, scan_id) }
                scanners = scanners[1:]
                scan_id -= 1

                continue find_scanner 

              } else { continue find_beacon }

            }
          }
        }
      }
    }
  }

  points := map[Vec]bool{}
  for known in &known_scanners {
    for beacon in &known.scan {
      points[beacon + known.pos] = true
    }
  }

  max_dist := 0
  for known in &known_scanners {
    for other in &known_scanners {
      max_dist = max(max_dist, norm_1(known.pos - other.pos))
    }
  }

  fmt.println("Part1:", len(points))
  fmt.println("part2:", max_dist)
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
