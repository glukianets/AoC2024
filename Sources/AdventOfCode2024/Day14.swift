import Foundation
import Algorithms
import Collections

class Day14A: DayCommand {
    typealias Input = [(position: Vec2D, velocity: Vec2D)]
    typealias Output = Int
    typealias Direction = Day6A.Direction
    typealias Vec2D = SIMD2<Int>

    required init() { /**/ }
   
    func parseInput(_ input: String) throws -> Input {
        let regex = /^p=(-?\d+),(-?\d+)\s*v=(-?\d+),(-?\d+)$/
        
        return try input.components(separatedBy: .newlines).map {
            guard let (_, px, py, vx, vy) = try regex.wholeMatch(in: $0)?.output else { throw "Invalid Input \($0)" }
            return try (
                Vec2D(Int(px).unwrapped, Int(py).unwrapped),
                Vec2D(Int(vx).unwrapped, Int(vy).unwrapped)
            )
        }
    }

    func run(_ input: Input) async throws -> Output {
        let size = Vec2D(101, 103)
        let time = 100
        
        let endPosition = input.lazy.map {
            ($0.position &+ size &* time &+ $0.velocity &* time) % size
        }
        
        return endPosition
            .filter { !any($0 .== size / 2) }
            .grouped { ($0 .< size / 2) }
            .mapValues(\.count)
            .values.reduce(1, *)
    }
}

class Day14B: Day14A {
    override func run(_ input: Day14A.Input) async throws -> Day14A.Output {
        let size = Vec2D(101, 103)
        let timeCap = 10000
       
        let states = sequence(first: input) { $0.map { (($0.position &+ size &+ $0.velocity) % size, $0.velocity) } }

        let time = states.prefix(timeCap).enumerated().map { ($0.offset, variance($0.element)) }.min { $0.1 < $1.1 }!.0

        return time
    }
    
    func variance(_ input: borrowing Input) -> Double {
        let positions = input.lazy.map(\.position)
        let center = positions.reduce(.zero, &+) / positions.count
        let deviance = positions.map { $0 &- center }
        let variance = deviance.map { sqrt(Double(($0 &* $0).wrappedSum())) }.reduce(0.0, +)
        return variance
    }
}
