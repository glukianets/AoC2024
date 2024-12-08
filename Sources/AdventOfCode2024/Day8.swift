import Foundation
import Algorithms

class Day8A: DayCommand {
    typealias Input = (size: Position, antennas: [(location: Position, name: Character)])
    typealias Output = Int
    
    required init() { /**/ }
   
    typealias Position = Day6A.Position
    typealias Direction = Day6A.Direction

    func parseInput(_ input: String) throws -> Input {
        let antennas = input.components(separatedBy: .newlines).enumerated().flatMap { y, line in
            line.enumerated().map { x, name -> (Position, Character) in (Position(x, y), name) }
        }
        let size = try Position(antennas.lazy.map(\.0.x).max().unwrapped, antennas.lazy.map(\.0.x).max().unwrapped)
        return (size, antennas.filter { $0.1.isLetter || $0.1.isNumber })
    }
    
    func run(_ input: Input) throws -> Output {
        let result: [Position] = input.antennas
            .grouped { $0.name }
            .mapValues { $0.map { $0.location } }
            .values.flatMap {
                product($0, $0).filter { $0 != $1 }.flatMap { l, r in
                    antinodes(lhs: l, rhs: r).prefix {
                        (0...input.size.x).contains($0.x) && (0...input.size.y).contains($0.y)
                    }
                }
            }
                
        return Set(result).count
    }
    
    func antinodes(lhs: Position, rhs: Position) -> any Sequence<Position> {
        [Position(lhs.x + (rhs.x - lhs.x) * 2, lhs.y + (rhs.y - lhs.y) * 2)]
    }
}

class Day8B: Day8A {
    override func antinodes(lhs: Position, rhs: Position) -> any Sequence<Position> {
        sequence(first: rhs) { $0 + rhs - lhs }
    }
}
