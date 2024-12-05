import Foundation

class Day2A: DayCommand {
    typealias Input = [[Int]]
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map {
            try $0.components(separatedBy: .whitespaces).map { try Int($0).unwrapped }
        }
    }

    func run(_ input: Input) throws -> Output {
        input.count { reading in
            let pairs = zip(reading, reading.dropFirst()).map { $0 - $1 }
            return pairs.allSatisfy { (1 ... 3) ~= $0 }
                || pairs.allSatisfy { (-3 ... -1) ~= $0 }
        }
    }
}

import Algorithms

class Day2B: Day2A {
    override func run(_ input: Input) throws -> Output {
        func test<T: Numeric>(_ input: some Sequence<T>, predicate: (T) -> Bool) -> Int? {
            zip(input, input.dropFirst()).lazy.map { $0 - $1 }.firstIndex { !predicate($0) }
        }
        
        let predicates = [{ (1 ... 3) ~= $0 }, { (-3 ... -1) ~= $0 }]
        
        return input.count { reading in
            predicates.contains { predicate in
                test(reading, predicate: predicate).map {
                    test([reading[..<$0],       reading[($0+1)...]].joined(), predicate: predicate) == nil ||
                    test([reading[..<($0+1)],   reading[($0+2)...]].joined(), predicate: predicate) == nil
                } ?? true
            }
        }
    }
}
