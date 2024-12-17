import Foundation
import Collections

// Today I've decided I'll write everything imperative for some reason

class Day6A: DayCommand {
    typealias Input = (start: (location: Vec2D, direction: Direction), size: Vec2D, walls: Set<Vec2D>)
    typealias Output = Int
    typealias VisitedType = OrderedDictionary<Vec2D, Direction>
    
    required init() { /**/ }
   
    typealias Vec2D = SIMD2<Int>

    
    struct Direction: OptionSet, CaseIterable, LosslessStringConvertible {
        static let none: Self = []
        static let left = Self(rawValue: 1 << 0)
        static let right = Self(rawValue: 1 << 1)
        static let down = Self(rawValue: 1 << 2)
        static let up = Self(rawValue: 1 << 3)
       
        static let allCases: [Self] = [.up, .right, .down, .left]
        
        let rawValue: Int
        
        var vector: Vec2D {
            Vec2D(
                ((self.rawValue >> 1) & 1) - (self.rawValue & 1),
                ((self.rawValue >> 2) & 1) - ((self.rawValue >> 3) & 1)
            )
        }
        
        var cases: some Collection<Self> { Self.allCases.lazy.filter(self.contains(_:)) }
        
        var inverse: Self {
            Self(rawValue: ~self.rawValue & 0b1111)
        }
        
        var opposite: Self {
            switch self {
            case .left: .right
            case .right: .left
            case .up: .down
            case .down: .up
            default: .none
            }
        }
        
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
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        init(_ position: Vec2D) {
            let (dx, dy) = (position.x.signum(), position.y.signum())
              self.rawValue = ((2 - ((dx >> 1) & 1)) * (dx * dx)) | (((((dy >> 1) & 1) + 1) << 2) * (dy * dy));
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
        
        var cw: Self {
            Self.allCases[(Self.allCases.firstIndex(of: self)! + 1) % Self.allCases.count]
        }
        
        var ccw: Self {
            Self.allCases[(Self.allCases.firstIndex(of: self)! - 1 + Self.allCases.count) % Self.allCases.count]
        }
    }
    
    func parseInput(_ input: String) throws -> Input {
        var walls: Set<Vec2D> = []
        var start: (location: Vec2D, direction: Direction)?
        var size = Vec2D(0, 0)
        
        let lines = input.components(separatedBy: .newlines)
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                switch char {
                case "#":
                    walls.insert(Vec2D(x, y))
                case "^":
                    start = (Vec2D(x, y), .up)
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
        var log: [(Vec2D, Direction)] = [input.start]
        
        assert(traverse(size: input.size, map: &visited, log: &log, obstacles: input.walls))
        
        return visited.count
    }
    
    
    func traverse(
        size: Vec2D,
        map: inout VisitedType,
        log: inout [(Vec2D, Direction)],
        obstacles: Set<Vec2D>
    ) -> Bool {
        guard var (location, direction) = log.popLast() else { return true }
        
        while (0..<size.x).contains(location.x) && (0..<size.y).contains(location.y) {
            guard !map[location, default: .none].contains(direction) else { return false }
            map[location, default: .none].insert(direction)
            log.append((location, direction))
            let nextLocation = location &+ direction.vector
            if obstacles.contains(nextLocation) {
                direction = direction.cw
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
        var log: [(Vec2D, Direction)] = [input.start]
        
        assert(traverse(size: input.size, map: &map, log: &log, obstacles: input.walls))
        
        var result: Set<Vec2D> = []
        map.removeAll()
        
        for (index, (location, directions)) in log.enumerated() {
            for direction in Direction.allCases where directions.contains(direction) {
                let next = location &+ direction.vector
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
