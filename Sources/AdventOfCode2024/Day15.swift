import Foundation
import Algorithms
import Collections

struct Day15A: DayCommand {
    typealias Input = (map: [Position: Obstacle], program: [Direction])
    typealias Output = Int
    
    typealias Position = Day6A.Vec2D
    typealias Direction = Day6A.Direction

    enum Obstacle {
        case wall, box, robot
    }
   
    func parseInput(_ input: String) throws -> Input {
        let halves = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces ) }
            .split(separator: "")
        
        guard let map = halves.first, let program = halves.last, halves.count == 2 else { throw "Invalid Input" }
                
        let parsedMap: [Position: Obstacle] = .init(
            uniqueKeysWithValues: map.enumerated().flatMap { y, line in
                line.enumerated().compactMap { x, char in
                    switch char {
                    case "#": (Position(x, y), .wall)
                    case "O": (Position(x, y), .box)
                    case "@": (Position(x, y), .robot)
                    default: nil
                    }
                }
            }
        )
        
        let parsedProgram = try program.joined().map { try Direction(String($0)).unwrapped }
        
        return (parsedMap, parsedProgram)
    }

    func run(_ input: Input) async throws -> Output {
        func tryMove(at position: Position, to direction: Direction, in map: inout [Position: Obstacle]) -> Bool {
            switch map[position] {
            case .wall:
                return false
            case .box, .robot:
                let next = position &+ direction.vector
                guard tryMove(at: next, to: direction, in: &map) else { return false }
                map[next] = map.removeValue(forKey: position)
                return true
            case nil:
                return true
            }
        }

        let (map, program) = input
        guard let robot = map.first(where: { $0.value == .robot })?.key else { throw "Invalid map state" }

        return program.reduce(into: (robot: robot, map: map)) { acc, command in
            if tryMove(at: acc.robot, to: command, in: &acc.map) {
                acc.robot &+= command.vector
            }
        }.map.filter { $0.value == .box }.map { 100 * $0.key.y + $0.key.x }.reduce(0, +)
    }
}

struct Day15B: DayCommand {
    typealias Input = (map: [Vec2D: Obstacle], program: [Direction])
    typealias Output = Int
    typealias Vec2D = SIMD2<Int>
    typealias Direction = Day6A.Direction

    enum Obstacle: Equatable {
        case wall, box(isLeft: Bool), robot
    }
   
    func parseInput(_ input: String) throws -> Input {
        let halves = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces ) }
            .split(separator: "")
        
        guard let map = halves.first, let program = halves.last, halves.count == 2 else { throw "Invalid Input" }
                
        let parsedMap: [Vec2D: Obstacle] = .init(
            uniqueKeysWithValues: map.enumerated().flatMap { y, line in
                line.enumerated().flatMap { x, char -> [(Vec2D, Obstacle)] in
                    switch char {
                    case "#": [(Vec2D(x * 2, y), .wall), (Vec2D(x * 2 + 1, y), .wall)]
                    case "O": [(Vec2D(x * 2, y), .box(isLeft: true)), (Vec2D(x * 2 + 1, y), .box(isLeft: false))]
                    case "@": [(Vec2D(x * 2, y), .robot)]
                    default: []
                    }
                }
            }
        )
        
        let parsedProgram = try program.joined().map { try Direction(String($0)).unwrapped }
        
        return (parsedMap, parsedProgram)
    }

    func run(_ input: Input) async throws -> Output {
        func tryMove(
            at position: Vec2D,
            to direction: Direction,
            in map: inout [Vec2D: Obstacle],
            dryRun: Bool
        ) -> Bool {
            switch map[position] {
            case .box(let isLeft):
                guard direction == .up || direction == .down else {
                    return _tryMove(at: position, to: direction, in: &map, dryRun: dryRun)
                }
                
                let adjascent = position &+ (isLeft ? Direction.right.vector : Direction.left.vector)
                guard
                    _tryMove(at: position, to: direction, in: &map, dryRun: true),
                    _tryMove(at: adjascent, to: direction, in: &map, dryRun: true)
                else { return false }
                precondition(_tryMove(at: position, to: direction, in: &map, dryRun: dryRun))
                precondition(_tryMove(at: adjascent, to: direction, in: &map, dryRun: dryRun))
                return true

            case .robot:
                return _tryMove(at: position, to: direction, in: &map, dryRun: dryRun)

            case .wall:
                return false

            case nil:
                return true
            }
        }
        
        func _tryMove(
            at position: Vec2D,
            to direction: Direction,
            in map: inout [Vec2D: Obstacle],
            dryRun: Bool
        ) -> Bool {
            let next = position &+ direction.vector
            guard tryMove(at: next, to: direction, in: &map, dryRun: dryRun) else { return false }
            if !dryRun {
                map[next] = map.removeValue(forKey: position)
            }
            return true
        }

        let (map, program) = input
        guard let robot = map.first(where: { $0.value == .robot })?.key else { throw "Invalid map state" }
        
        return program.reduce(into: (robot: robot, map: map)) { acc, command in
            if tryMove(at: acc.robot, to: command, in: &acc.map, dryRun: false) {
                acc.robot &+= command.vector
            }
        }.map.filter { if case .box(isLeft: true) = $0.value { true } else { false } }.map { 100 * $0.key.y + $0.key.x }.reduce(0, +)
    }
}
