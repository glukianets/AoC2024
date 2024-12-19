import Foundation
import Collections

class Day18A: DayCommand {
    typealias Input = [Vec2D]
    typealias Output = String
    typealias Vec2D = Day6A.Vec2D
    typealias Direction = Day6A.Direction
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map {
            let numbers = $0.components(separatedBy: ",").compactMap { Int($0)  }
            guard numbers.count == 2 else { throw "failed to parse \(numbers)" }
            return Vec2D(numbers[0], numbers[1])
        }
    }

    func run(_ input: Input) async -> Output {
        let input = input.prefix(1024)
        guard let result = simulate(input) else { return "no path" }
        return "\(result)"
    }
    
    func simulate(_ input: some Sequence<Input.Element>) -> Int? {
        let input = Set(input)
        let start: Vec2D = .zero, end: Vec2D = [70, 70]
        
        var queue: Deque<Vec2D> = [start]
        var traverseMap: [Vec2D: Int] = [start: 0]
        
        while let current = queue.popFirst() {
            guard let existing = traverseMap[current] else { fatalError("unreachable") }
            let neighbors: [Vec2D] = Direction.allCases.map { current &+ $0.vector }
                .filter { traverseMap[$0] == nil && !input.contains($0) && all(($0 .<= end) .& ($0 .>= start)) }
            
            for neighbor in neighbors where traverseMap[neighbor, default: .max] > existing + 1 {
                traverseMap[neighbor] = existing + 1
                queue.append(neighbor)
            }
        }

        return traverseMap[end]
    }
}

class Day18B: Day18A {
    override func run(_ input: Input) async -> Output {  
        for limit in (1...input.count).reversed() {
            if let _ = super.simulate(input.prefix(limit)) {
                return "\(input[limit].x),\(input[limit].y)"
            }
        }
        
        return "Failed"
    }
}
