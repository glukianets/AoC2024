import Foundation
import Algorithms
import Collections

class Day15A: DayCommand {
    typealias Input = (map: [Position: Obstacle], program: [Direction])
    typealias Output = Int

    required init() { /**/ }
    
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

class Day15B: DayCommand {
    typealias Input = (map: [Position: Obstacle], program: [Direction])
    typealias Output = Int
    typealias Position = SIMD2<Int>

    required init() { /**/ }
    
    enum Obstacle: Equatable {
        case wall, box(isLeft: Bool), robot
    }
   
    func parseInput(_ input: String) throws -> Input {
        let halves = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces ) }
            .split(separator: "")
        
        guard let map = halves.first, let program = halves.last, halves.count == 2 else { throw "Invalid Input" }
                
        let parsedMap: [Position: Obstacle] = .init(
            uniqueKeysWithValues: map.enumerated().flatMap { y, line in
                line.enumerated().flatMap { x, char -> [(Position, Obstacle)] in
                    switch char {
                    case "#": [(Position(x * 2, y), .wall), (Position(x * 2 + 1, y), .wall)]
                    case "O": [(Position(x * 2, y), .box(isLeft: true)), (Position(x * 2 + 1, y), .box(isLeft: false))]
                    case "@": [(Position(x * 2, y), .robot)]
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
            at position: Position,
            to direction: Direction,
            in map: inout [Position: Obstacle],
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
            at position: Position,
            to direction: Direction,
            in map: inout [Position: Obstacle],
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

typealias Position = SIMD2<Int>

struct Direction: OptionSet, CaseIterable {
    static let none: Self = []
    static let left = Self(rawValue: 1 << 0)
    static let right = Self(rawValue: 1 << 1)
    static let down = Self(rawValue: 1 << 2)
    static let up = Self(rawValue: 1 << 3)
   
    static let allCases: [Self] = [.up, .right, .down, .left]
    
    let rawValue: Int
    
    var description: String {
        switch self {
        case .left: "<"
        case .right: ">"
        case .down: "v"
        case .up: "^"
        case .none: "."
        default: "*"
        }
    }
    
    var vector: Position {
        Position(
            ((self.rawValue >> 1) & 1) - (self.rawValue & 1),
            ((self.rawValue >> 2) & 1) - ((self.rawValue >> 3) & 1)
        )
    }
    
    var cases: some Collection<Self> { Self.allCases.lazy.filter(self.contains(_:)) }
    
    var inverse: Self {
        Self(rawValue: ~self.rawValue & 0b1111)
    }
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init?(_ string: some StringProtocol) {
        switch string {
        case "<": self = .left
        case ">": self = .right
        case "v": self = .down
        case "^": self = .up
        default: return nil
        }
    }
    
    init(_ position: Position) {
        let (dx, dy) = (position.x.signum(), position.y.signum())
        self.rawValue = ((2 - ((dx >> 1) & 1)) * (dx * dx)) | (((((dy >> 1) & 1) + 1) << 2) * (dy * dy));
    }
}
