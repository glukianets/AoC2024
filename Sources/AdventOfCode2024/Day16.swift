import Foundation
import Collections

class Day16A: DayCommand {
    enum Cell: String {
        case wall = "#"
        case none = "."
        case start = "S"
        case finish = "E"
    }
    
    typealias Input = [[Cell]]
    typealias Output = Int
    typealias Direction = Day6A.Direction
    typealias Vec2D = Day6A.Vec2D

    struct Mark: Equatable {
        var turns: Int, steps: Int, direction: Direction
        var metric: Int { turns * 1000 + steps }
    }
    
    required init() { /**/ }
    
    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).map {
            try $0.map { try Cell(rawValue: String($0)).unwrapped }
        }
    }

    func run(_ input: Input) async throws -> Output {
        guard
            let start = input.indices2d.first(where: { input[$0.y][$0.x] == .start }).map({ Vec2D($0.x, $0.y) }),
            let finish = input.indices2d.first(where: { input[$0.y][$0.x] == .finish }).map({ Vec2D($0.x, $0.y) })
        else { throw "InvalidInput"}
        

        var traverseMap: [[Mark?]] = input.map {
            Array(repeating: nil, count: $0.count)
        }
        
        traverseMap[finish.y][finish.x] = Mark(turns: 0, steps: 0, direction: .none)
        
        func printTraverseMap(_ map: [[Mark?]], position: Vec2D) {
            for (y, line) in map.enumerated() {
                for (x, cell) in line.enumerated() {
                    if position == [x, y] {
                        print("@", terminator: "")
                    } else if input[y][x] == .wall {
                        print("#", terminator: "")
                    } else if let mark = cell {
                        print(mark.direction.description, terminator: "")
                    } else {
                        print(" ", terminator: "")
                    }
                }
                print(";")
            }
        }
        
        var breadcrumbs: Deque<(Direction, Vec2D)> = [(.none, finish)]
        let target = start
        
        while let (direction, position) = breadcrumbs.popFirst() {
            guard position != target else { continue }
            guard let mark = traverseMap[position.y][position.x] else { fatalError("unreachable") }
  
            let neighbors: [(Direction, Vec2D)] = Direction.allCases.map { ($0, position &+ $0.opposite.vector) }
                .filter { $0.0 != direction.opposite && input[$0.1.y][$0.1.x] != .wall }
   
            for (newDirection, newPosition) in neighbors {
                let newMark = Mark(
                    turns: mark.turns + (direction.contains(newDirection) ? 0 : 1 ),
                    steps: mark.steps + 1,
                    direction: newDirection
                )
                
                switch traverseMap[newPosition.y][newPosition.x] {
                case let mark? where newMark.metric < mark.metric:
                    fallthrough
                case nil:
                    traverseMap[newPosition.y][newPosition.x] = newMark
                    breadcrumbs.append((newDirection, newPosition))
                default:
                    break
                }
            }
        }
        
        printTraverseMap(traverseMap, position: finish)
        
        return self.tracePath(in: traverseMap, startingFrom: start)
    }
    
    func tracePath(in traverseMap: [[Mark?]], startingFrom start: Vec2D) -> Int {
        let path = sequence(first: start) { current in
            guard let mark = traverseMap[current.y][current.x], mark.direction != .none else { return nil }
            return current &+ mark.direction.vector
        }

        let pathSet = Set(path)
        
        for (y, line) in traverseMap.enumerated() {
            for (x, _) in line.enumerated() {
//                if input[y][x] == .wall {
//                    print("#", terminator: "")
//                } else
                if let mark = traverseMap[y][x], pathSet.contains(Vec2D(x, y)) {
                    print(mark.direction.description, terminator: "")
                } else {
                    print(" ", terminator: "")
                }
            }
            print(";")
        }
        
        var mark = path.lazy
            .map { traverseMap[$0.y][$0.x]! }
            .dropFirst()
            .reduce(into: Mark(turns: 0, steps: 0, direction: .right)) { a, e in
                a.turns += e.direction == a.direction ? 0 : 1
                a.steps += 1
                a.direction = e.direction
            }
        
        mark.turns -= 1
        return mark.metric
    }
}

class Day16B: Day16A {
    override func run(_ input: Day16A.Input) async throws -> Day16A.Output {
        try! await Task.sleep(for: .seconds(3))
        return try await super.run(input)
    }
    
    override func tracePath(in traverseMap: [[Mark?]], startingFrom start: Vec2D) -> Int {
        var pathSet: Set<Vec2D> = []

        func fold(at position: Vec2D) {
            pathSet.insert(position)
            
            let neighbors =  Direction.allCases
                .map { ($0, position &+ $0.vector) }
                .compactMap { d, p -> (Direction, Mark)? in
                    guard
                        !pathSet.contains(p),
                        let mark = traverseMap[p.y][p.x],
                        mark.direction != d.opposite
                    else { return nil }
                    return (d, mark)
                }
            
           
            neighbors
                .grouped { $0.1.metric }
                .min { $0.key < $1.key }?
                .value.forEach { fold(at: position &+ $0.0.vector) }
        }
        
        fold(at: start)

        for (y, line) in traverseMap.enumerated() {
            for (x, _) in line.enumerated() {
//                if input[y][x] == .wall {
//                    print("#", terminator: "")
//                } else
                if pathSet.contains(Vec2D(x, y)) {
                    print("O", terminator: "")
                } else {
                    print(" ", terminator: "")
                }
            }
            print(";")
        }
        
        return pathSet.count
    }
}
