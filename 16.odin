package aoc16

import "core:fmt"
import "core:slice"

BitStream :: struct {
  source: []u8,
  ind: int,
}

hexdigit :: proc (c: u8) -> (int, bool) {
  switch c {
    case '0'..'9':
      return int(c - '0'), true
    case 'A'..'F':
      return int(c - 'A' + 10), true
    case 'a'..'f':
      return int(c - 'a' + 10), true
    case:
      return 0, false
  }
}

next :: proc (using b: ^BitStream) -> (res: int, ok: bool) {
  if len(source) > ind / 4 {
    digit := hexdigit(source[ind/4]) or_return
    defer ind += 1
    return (digit >> uint(3 - (ind % 4))) & 1, true
  }
  return 0, false
}

LiteralValue :: struct {
  value: int,
}

OperatorType :: enum {
  Sum = 0,
  Product = 1,
  Minimum = 2,
  Maximum = 3,
  Greater = 5,
  Less = 6,
  Equal = 7,
}

Operator :: struct {
  type: OperatorType,
  children: [dynamic]Packet,
}

Packet :: struct {
  version: int,
  inner: union {
    LiteralValue,
    Operator,
  },
}

parse_literal :: proc (b: ^BitStream) -> (res: LiteralValue, ok: bool) {
  for flag := 1; flag == 1; {
    flag = next(b) or_return
    for _ in 1..4 {
      bit := next(b) or_return
      res.value = res.value * 2 + bit
    }
  }
  return res, true
}

parse_operator :: proc (b: ^BitStream, t: OperatorType) -> (res: Operator, ok: bool) {
  res.type = t
  length_type_id := next(b) or_return
  switch length_type_id {
    case 0:
      length := 0
      for _ in 1..15 {
        bit := next(b) or_return
        length = length * 2 + bit
      }
      start_index := b.ind
      for b.ind < start_index + length {
        child, ok := parse_packet(b)
        if !ok {
          fmt.println("invalid child", len(res.children), ", parsed a total of", b.ind - start_index)
          return res, false
        }
        append(&res.children, child)
      }
      return res, b.ind == start_index + length
    case 1:
      n_child := 0
      for _ in 1..11 {
        bit := next(b) or_return
        n_child  = n_child * 2 + bit
      }
      for len(res.children) < n_child {
        child, ok := parse_packet(b)
        if !ok {
          fmt.println("invalid child", len(res.children), "out of", n_child)
          return res, false
        }
        append(&res.children, child)
      }
      return res, true
  }
  return res, ok
}

parse_packet :: proc (b: ^BitStream) -> (res: Packet, ok: bool) {
  for _ in 1..3 {
    bit := next(b) or_return
    res.version = res.version * 2 + bit
  }

  type_id := 0
  for _ in 1..3 {
    bit := next(b) or_return
    type_id = type_id * 2 + bit
  }

  switch type_id {
    case 4:
      res.inner = parse_literal(b) or_return
      return res, true
    case :
      res.inner = parse_operator(b, OperatorType(type_id)) or_return
      return res, true
  }
}

sum_all_versions :: proc (p: Packet) -> int {
  total := p.version
  switch i in p.inner {
    case LiteralValue:
    case Operator:
      for child in i.children {
        total += sum_all_versions(child)
      }
  }
  return total
}

evaluate_packet :: proc (p: Packet) -> int {
  switch i in p.inner {
    case LiteralValue:
      return i.value
    case Operator:
      switch i.type {
        case .Sum:
          result := 0
          for subp in i.children {result += evaluate_packet(subp)}
          return result
        case .Product:
          result := 1
          for subp in i.children {result *= evaluate_packet(subp)}
          return result
        case .Maximum:
          result := min(int)
          for subp in i.children {
            result = max(result, evaluate_packet(subp))
          }
          return result
        case .Minimum:
          result := max(int)
          for subp in i.children {
            result = min(result, evaluate_packet(subp))
          }
          return result
        case .Greater:
          return int(evaluate_packet(i.children[0]) > evaluate_packet(i.children[1]))
        case .Less:
          return int(evaluate_packet(i.children[0]) < evaluate_packet(i.children[1]))
        case .Equal:
          return int(evaluate_packet(i.children[0]) == evaluate_packet(i.children[1]))
        case:
          fmt.println("Unknown operation", i.type)
          return 0
      }
    case:
      fmt.println("Unknown packet type")
      return 0
  }
}

main :: proc () {
  when ODIN_DEBUG {
    for input in inputs_1 {
      b := BitStream{transmute([]u8)input, 0}
      p, _ := parse_packet(&b)
      fmt.println("Part1: ", sum_all_versions(p))
    }

    for input in inputs_2 {
      b := BitStream{transmute([]u8)input, 0}
      p, _ := parse_packet(&b)
      fmt.println("Part2: ", evaluate_packet(p))
    }
  } else {
    b := BitStream{input, 0}
    p, _ := parse_packet(&b)
    fmt.println("Part1:", sum_all_versions(p))
    fmt.println("Part2:", evaluate_packet(p))
  }
}

when ODIN_DEBUG {
  inputs_1 := []string {
    "8A004A801A8002F478",
    "620080001611562C8802118E34",
    "C0015000016115A2E0802F182340",
    "A0016C880162017C3686B18A3D4780",
  }
  inputs_2 := []string {
    "C200B40A82",
    "04005AC33890",
    "880086C3E88112",
    "CE00C43D881120",
    "D8005AC2A8F0",
    "F600BC2D8F",
    "9C005AC2F8F0",
    "9C0141080250320F1802104A08",
  }

} else {
  input :: #load("16.txt")
}
