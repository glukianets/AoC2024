import Foundation
import Algorithms
import Collections

class Day12A: DayCommand {
    typealias Input = [[UInt16]]
    typealias Output = Int
    typealias Direction = Day6A.Direction
    typealias Position = Day6A.Position

    required init() { /**/ }
   
    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).map {
            try $0.trimmingCharacters(in: .whitespaces).map { try UInt16($0.asciiValue.unwrapped) }
        }
    }
    
    @_optimize(speed)
    func run(_ input: Input) async throws -> Output {
        var edgeMap: [[(name: UInt16, walls: Direction)]] = input.map { Array(repeating: (0, .none), count: $0.count) }
        
        func mapRegion(y: Int, x: Int) -> (Int, Int) {
            guard edgeMap[y][x].name == 0 else { return (0, 0) }
            
            let walls = Direction.allCases.filter { direction in
                let (dx, dy) = (x + direction.vector.x, y + direction.vector.y)
                return !input.indices.contains(dy) || !input[dy].indices.contains(dx) || input[dy][dx] != input[y][x]
            }.reduce(into: Direction.none) { a, e in a.formUnion(e) }
            
            edgeMap[y][x] = (input[y][x], walls)
            
            return walls.inverse.cases
                .map { mapRegion(y: y + $0.vector.y, x: x + $0.vector.x) }
                .reduce((1, walls.cases.count)) { a, e in (a.0 + e.0, a.1 + e.1) }
        }
        
        var result: Int = 0
        for (y, x) in input.indices2d where edgeMap[y][x].name == 0 {
            let (area, perimeter) = mapRegion(y: y, x: x)
            result += area * perimeter
        }
        
        return result
    }
}

class Day12B: Day12A {
    @_optimize(speed)
    override func run(_ input: Input) async throws -> Output {
        var edgeMap: [[UInt16]] = input.map { Array(repeating: 0, count: $0.count) }
        
        func mapRegion(y: Int, x: Int, name: UInt16) {
            guard edgeMap[y][x] == 0 else { return }
            
            let neighbors = Direction.allCases.filter { direction in
                let (dx, dy) = (x + direction.vector.x, y + direction.vector.y)
                return input.indices.contains(dy) && input[dy].indices.contains(dx) && input[dy][dx] == input[y][x]
            }.reduce(into: Direction.none) { a, e in a.formUnion(e) }
            
            edgeMap[y][x] = name
            
            neighbors.cases.forEach { mapRegion(y: y + $0.vector.y, x: x + $0.vector.x, name: name) }
        }
        
        var name: UInt16 = 1
        for (y, x) in input.indices2d where edgeMap[y][x] == 0 {
            mapRegion(y: y, x: x, name: name)
            name += 1
        }
        
        let width = edgeMap.first!.count
        edgeMap.insert(Array(repeating: 0, count: width), at: 0)
        edgeMap.append(Array(repeating: 0, count: width))
        for i in edgeMap.indices {
            edgeMap[i].insert(0, at: 0)
            edgeMap[i].append(0)
        }

        // tl | tr
        // ---+---
        // bl | br
                
        let quads: some Sequence<(tl: UInt16, tr: UInt16, bl: UInt16, br: UInt16)> = edgeMap.adjacentPairs().flatMap {
            zip($0.adjacentPairs(), $1.adjacentPairs()).map { ($0.0.0, $0.0.1, $0.1.0, $0.1.1)}
        }
        
        return quads.reduce(into: [UInt16: (area: Int, sides: Int)]()) { a, quad in
            a[quad.tl, default: (0, 0)].area += 1
            a[quad.tr, default: (0, 0)].area += 1
            a[quad.bl, default: (0, 0)].area += 1
            a[quad.br, default: (0, 0)].area += 1
            a[quad.tl]!.sides += quad.tl != quad.tr && (quad.tl != quad.bl || quad.bl == quad.br) ? 1 : 0
            a[quad.tr]!.sides += quad.tl != quad.tr && (quad.tr != quad.br || quad.bl == quad.br) ? 1 : 0
        }
        .compactMap { $0.key == 0 ? nil : $0.value }
        .map { $0.area / 4 * $0.sides * 2 }
        .reduce(0, +)
    }
}
