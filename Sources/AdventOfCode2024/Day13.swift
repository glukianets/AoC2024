import Foundation
import Algorithms
import Collections

class Day13A: DayCommand {
    typealias Input = [(a: Position, b: Position, prize: Position)]
    typealias Output = Int
    typealias Direction = Day6A.Direction
    typealias Position = Day6A.Position

    required init() { /**/ }
   
    func parseInput(_ input: String) throws -> Input {
        let buttonRegex = /^Button [A-Za-z]: X\+(\d+), Y\+(\d+)$/
        let prizeRegex = /^Prize: X=(\d+), Y=(\d+)$/
        
        return try input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .split(separator: "")
            .map {
                guard $0.count == 3,
                      let (_, ax, ay) = try buttonRegex.wholeMatch(in: $0[$0.startIndex])?.output,
                      let (_, bx, by) = try buttonRegex.wholeMatch(in: $0[$0.startIndex+1])?.output,
                      let (_, px, py) = try prizeRegex.wholeMatch(in: $0[$0.startIndex+2])?.output
                else { throw "Invalid Input" }
                
                return try (
                    Position(Int(ax).unwrapped, Int(ay).unwrapped),
                    Position(Int(bx).unwrapped, Int(by).unwrapped),
                    Position(Int(px).unwrapped, Int(py).unwrapped)
                )
            }
    }

    func run(_ input: Input) async throws -> Output {
        input.compactMap { (a, b, c) in
            let positions: some Sequence<Position> = (0...100).flatMap { x in (0...100).map { y in Position(x, y) } }
            let combinations: some Sequence<Position> = positions
                .filter { Position($0.x * a.x + $0.y * b.x, $0.x * a.y + $0.y * b.y) == c }
            return combinations
                .min(by: { $0.x < $1.x || $0.x == $1.x && $0.y < $1.y })
                .map { $0.x * 3 + $0.y }
        }.reduce(0, +)
    }
}

class Day13B: Day13A {
    override func parseInput(_ input: String) throws -> Input {
        let result = try super.parseInput(input)
        let delta = Position(10000000000000, 10000000000000)
        
        return result.map {
            ($0.a, $0.b, $0.prize + delta)
        }
    }
    
    override func run(_ input: Day13A.Input) async throws -> Day13A.Output {
        func linearCombination(a: Position, b: Position, c: Position) -> Position? {
            let det = a.x * b.y - a.y * b.x

            guard det != 0 else { return nil }

            let sx = c.x * b.y - c.y * b.x
            let sy = a.x * c.y - a.y * c.x

            guard sx % det == 0 && sy % det == 0 else { return nil }

            let x = sx / det
            let y = sy / det

            guard x >= 0 && y >= 0 else { return nil }

            return Position(x, y)
        }
        
        return input
            .compactMap { linearCombination(a: $0.a, b: $0.b, c: $0.prize) }
            .map { $0.x * 3 + $0.y }
            .reduce(0, +)
    }
}
