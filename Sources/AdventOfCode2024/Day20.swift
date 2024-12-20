import Foundation
import Algorithms
import Collections

class Day20A: DayCommand {
    typealias Input = [[Cell]]
    typealias Output = Int
    typealias Direction = Day6A.Direction
    typealias Vec2D = Day6A.Vec2D
    typealias Cell = Day16A.Cell
    typealias Mark = Int
    
    required init() { /**/ }
    
    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).map {
            try $0.map { try Cell(rawValue: String($0)).unwrapped }
        }
    }

    func run(_ input: Input) async throws -> Output {
        let (start, finish, _) = try measure(input: input)

        var path: OrderedSet<Vec2D> = [start]
        var traverseMap: [[Mark?]] = input.map { Array(repeating: nil, count: $0.count) }
        traverseMap[start.y][start.x] = 0
        
        var position: (current: Vec2D, previous: Vec2D)? = (start, start)
        while let (current, previous) = position {
            guard let mark = traverseMap[current.y][current.x] else { fatalError() }
            for next in Direction.allCases.map({ current &+ $0.vector })
            where next != previous && input[next.y][next.x] != .wall {
                path.append(next)
                traverseMap[next.y][next.x] = mark + 1
                position = next != finish ? (next, current) : nil
            }
        }
        
        return try calculateResult(input: input, traverseMap: traverseMap, path: path)
    }
    
    func measure(input: Input) throws -> (start: Vec2D, finish: Vec2D, bound: Vec2D) {
        guard
            let start = input.indices2d.first(where: { input[$0.y][$0.x] == .start }).map({ Vec2D($0.x, $0.y) }),
            let finish = input.indices2d.first(where: { input[$0.y][$0.x] == .finish }).map({ Vec2D($0.x, $0.y) })
        else { throw "InvalidInput"}

        let bound: Vec2D = [input.count, input.max { $0.count < $1.count }!.count]

        return (start, finish, bound)
    }
    
    func calculateResult(input: Input, traverseMap: [[Mark?]], path: OrderedSet<Vec2D>) throws -> Int {
        let (_, _, bound) = try measure(input: input)

        var shortcuts: [(position: Vec2D, value: Int)] = []
        
        for current in path {
            guard let currentMark = traverseMap[current.y][current.x] else { fatalError() }
            
            for next in Direction.allCases.map({ current &+ $0.vector }) where input[next.y][next.x] == .wall {
                let shortcut = next &- current &+ next
                guard
                    all(shortcut .< bound .& shortcut .>= 0),
                    let skip = traverseMap[shortcut.y][shortcut.x],
                    skip > currentMark
                else { continue }
                shortcuts.append((shortcut, skip - currentMark - 2))
            }
        }
        
        return shortcuts.count { $0.value >= 100 }
    }
}

class Day20B: Day20A {
    struct Shortcut: Hashable  {
        var begin, end: Vec2D
        var distance: Int { abs(end.x - begin.x) + abs(end.y - begin.y) }
    }
    
    override func calculateResult(input: Day20A.Input, traverseMap: [[Day20A.Mark?]], path: OrderedSet<Vec2D>) throws -> Int {
        let (_, _, bound) = try measure(input: input)
        let maxDistance = 20, minShortcut = 100

        var shortcuts: Set<Shortcut> = []

        for current in path {
            guard let currentMark = traverseMap[current.y][current.x] else { fatalError() }
            let range = (-maxDistance...maxDistance)
            for delta in product(range, range).map({ Vec2D($0.0, $0.1) }) {
                let shortcut = Shortcut(begin: current, end: current &+ delta)
                guard
                    shortcut.distance <= maxDistance,
                    all(shortcut.end .< bound .& shortcut.end .>= 0),
                    let skip = traverseMap[shortcut.end.y][shortcut.end.x],
                    skip - currentMark >= shortcut.distance + minShortcut
                else { continue }
                shortcuts.insert(shortcut)
            }
        }

        return shortcuts.count
    }
}
