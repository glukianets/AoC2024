import Foundation
import Algorithms
import Collections

class Day10<Acc>: DayCommand {
    typealias Input = [[UInt8]]
    typealias Output = Int
    typealias Acc = Acc
    private typealias Direction = Day6A.Direction
    
    required init() { /**/ }
    
    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).map {
            try $0.trimmingCharacters(in: .whitespaces).map { try $0.asciiValue.unwrapped &- 48 }
        }
    }
    
    func run(_ input: Input) throws -> Output {
        var map: [[Acc?]] = input.map { $0.map { _ in nil } }
        
        func traverse(from x: Int, _ y: Int) -> Acc? {
            if let alreadyTraversed = map[y][x] { return alreadyTraversed }
            guard input[y][x] < 9 else { let value = self.one; map[y][x] = value; return value }
            
            let vicinity: some Sequence<(x: Int, y: Int)> = Direction.allCases.lazy
                .map { $0.vector }
                .map { (x + $0.x, y + $0.y) }
            
            let reachable: Acc = vicinity
                .filter { input.indices.contains($0.y) && input[y].indices.contains($0.x) }
                .filter { input[$0.y][$0.x] &- input[y][x] == 1 }
                .compactMap { traverse(from: $0.x, $0.y) }
                .reduce(self.zero) { self.join(lhs: $0, rhs: $1) }
            
            map[y][x] = reachable
            return reachable
        }

        let result: Int = input.indices.flatMap { y in input.indices.map { x in (x: x, y: y) } }
            .filter { input[$0.y][$0.x] == 0 }
            .compactMap { traverse(from: $0.x, $0.y) }
            .map { self.buildFinalResult($0) }
            .reduce(0, +)
        
        return result
    }
    
    var zero: Acc { fatalError("unimplemented") }
    var one: Acc { fatalError("unimplemented") }
    
    func join(lhs: Acc, rhs: Acc) -> Acc {
        fatalError("unimplemented")
    }
    
    func buildFinalResult(_ value: Acc) -> Int {
        fatalError("unimplemented")
    }
}

class Day10A: Day10<Set<Int>> {
    var uniquePeak: Int = 0
    
    override var zero: Acc { Set() }
    
    override var one: Acc {
        var result = Acc(minimumCapacity: 1)
        result.insert(self.uniquePeak)
        self.uniquePeak += 1
        return result
    }
    
    override func join(lhs: Acc, rhs: Acc) -> Acc {
        lhs.union(rhs)
    }
    
    override func buildFinalResult(_ value: Acc) -> Int {
        value.count
    }
}

class Day10B: Day10<Int> {
    override var zero: Acc { 0 }
    
    override var one: Acc { 1 }
    
    override func join(lhs: Acc, rhs: Acc) -> Acc {
        lhs + rhs
    }
    
    override func buildFinalResult(_ value: Acc) -> Int {
        value
    }
}
