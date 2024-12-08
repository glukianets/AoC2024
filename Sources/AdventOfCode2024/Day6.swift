import Foundation
import Collections

// Today I've decided I'll write everything imperative for some reason

class Day6A: DayCommand {
    typealias Input = (start: (location: Position, direction: Direction), size: Position, walls: Set<Position>)
    typealias Output = Int
    typealias VisitedType = OrderedDictionary<Position, Direction>
    
    required init() { /**/ }
   
    struct Position: Hashable {
        var x: Int, y: Int
        
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
        
        static func +(_ lhs: Self, _ rhs: Self) -> Self {
            .init(lhs.x + rhs.x, lhs.y + rhs.y)
        }
        
        static func -(_ lhs: Self, _ rhs: Self) -> Self {
            .init(lhs.x - rhs.x, lhs.y - rhs.y)
        }
    }
    
    struct Direction: OptionSet, CaseIterable {
        static let none: Self = []
        static let left = Self(rawValue: 1 << 0)
        static let right = Self(rawValue: 1 << 1)
        static let down = Self(rawValue: 1 << 2)
        static let up = Self(rawValue: 1 << 3)
       
        static let allCases: [Day6A.Direction] = [.up, .right, .down, .left]
        
        let rawValue: Int
        
        var vector: Position {
            Position(
                ((self.rawValue >> 1) & 1) - (self.rawValue & 1),
                ((self.rawValue >> 2) & 1) - ((self.rawValue >> 3) & 1)
            )
        }
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        init(_ position: Position) {
            let (dx, dy) = (position.x.signum(), position.y.signum())
              self.rawValue = ((2 - ((dx >> 1) & 1)) * (dx * dx)) | (((((dy >> 1) & 1) + 1) << 2) * (dy * dy));
        }
        
        var next: Self {
            Self.allCases[(Self.allCases.firstIndex(of: self)! + 1) % Self.allCases.count]
        }
    }
    
    func parseInput(_ input: String) throws -> Input {
        var walls: Set<Position> = []
        var start: (location: Position, direction: Direction)?
        var size = Position(0, 0)
        
        let lines = input.components(separatedBy: .newlines)
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                switch char {
                case "#":
                    walls.insert(Position(x, y))
                case "^":
                    start = (Position(x, y), .up)
                default:
                    continue
                }
            }
            size.x = max(size.x, line.count)
        }
        size.y = lines.count
        
        return try (start.unwrapped, size, walls)
    }
    
    func run(_ input: Input) throws -> Output {
        var visited: VisitedType = [:]
        var log: [(Position, Direction)] = [input.start]
        
        assert(traverse(size: input.size, map: &visited, log: &log, obstacles: input.walls))
        
        return visited.count
    }
    
    
    func traverse(
        size: Position,
        map: inout VisitedType,
        log: inout [(Position, Direction)],
        obstacles: Set<Position>
    ) -> Bool {
        guard var (location, direction) = log.popLast() else { return true }
        
        while (0..<size.x).contains(location.x) && (0..<size.y).contains(location.y) {
            guard !map[location, default: .none].contains(direction) else { return false }
            map[location, default: .none].insert(direction)
            log.append((location, direction))
            let nextLocation = location + direction.vector
            if obstacles.contains(nextLocation) {
                direction = direction.next
            } else {
                location = nextLocation
            }
        }
        
        return true
    }
}

class Day6B: Day6A {
    @_optimize(speed)
    override func run(_ input: Input) throws -> Output {
        var map: VisitedType = [:]
        var log: [(Position, Direction)] = [input.start]
        
        assert(traverse(size: input.size, map: &map, log: &log, obstacles: input.walls))
        
        var result: Set<Position> = []
        map.removeAll()
        
        for (index, (location, directions)) in log.enumerated() {
            for direction in Direction.allCases where directions.contains(direction) {
                let next = location + direction.vector
                guard (0..<input.size.x).contains(next.x)
                   && (0..<input.size.y).contains(next.y)
                   && map[next, default: .none] == .none
                else { continue }

                var log = Array(log[0...index])
                var visited: VisitedType = [:]
                var obstacles = input.walls
                obstacles.insert(next)
                
                if !traverse(size: input.size, map: &visited, log: &log, obstacles: obstacles) {
                    result.insert(next)
                }
            }
            map[location] = directions
        }
        
        return result.count
    }
}
