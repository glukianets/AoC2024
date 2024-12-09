import Foundation
import Algorithms
import Collections

class Day9A: DayCommand {
    typealias Input = [(id: Int, range: Range<Int>)]
    typealias Output = Int
    
    required init() { /**/ }
   
    func parseInput(_ input: String) throws -> Input {
        try input.map {
            try Int($0.asciiValue.unwrapped - 48)
        }.enumerated().reduce(into: (0, [] as [(Int, Range<Int>)])) { a, e in
            a.1.append((e.offset % 2 == 0 ? e.offset / 2 : -1, a.0 ..< a.0+e.element))
            a.0 += e.element
        }.1
    }
    
    func run(_ input: Input) throws -> Output {
        var input = Deque(input)
        var result: Input = []
    
        while let segment = input.popFirst() {
            guard segment.id < 0 else { result.append(segment); continue }
            var gap = segment.range
            while !gap.isEmpty, let (id, range) = input.popLast() {
                guard id >= 0 else { continue }
                let portionLength = min(gap.count, range.count)
                let insertion = gap.lowerBound ..< gap.lowerBound + portionLength
                result.append((id, insertion))
                if portionLength < range.count {
                    input.append((id, range.lowerBound ..< range.upperBound - portionLength))
                    break
                } else {
                    gap = gap.lowerBound + portionLength ..< gap.upperBound
                }
            }
        }
        
        return checksum(result)
    }
    
    func checksum(_ ranges: [(Int, Range<Int>)]) -> Int {
        ranges.lazy.flatMap { it in it.1.map { $0 * it.0 } }.reduce(0, +)
    }
    
    func description(_ ranges: [(Int, Range<Int>)]) -> String {
        ranges.map { String(repeating: $0.0 >= 0 ? "\($0.0)" : ".", count: $0.1.count) }.joined()
    }
}

class Day9B: Day9A {
    override func run(_ input: Day9A.Input) throws -> Day9A.Output {
        var input = Deque(input)
        var result: Input = []

        while let gap = input.popFirst() {
            guard gap.id < 0 else { result.append(gap); continue }
            guard let index = input.indices.reversed().lazy.first(where: {
                input[$0].id >= 0 && input[$0].range.count <= gap.range.count
            }) else { continue }
            let segment = input.remove(at: index)
            let partitionPoint = gap.range.lowerBound + segment.range.count
            result.append((segment.id, gap.range.lowerBound ..< partitionPoint))
            guard partitionPoint < gap.range.upperBound else { continue }
            input.prepend((gap.id, partitionPoint ..< gap.range.upperBound))
        }
        
        return checksum(result.filter { $0.id >= 0 })
    }
}
