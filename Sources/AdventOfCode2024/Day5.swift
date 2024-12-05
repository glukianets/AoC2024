import Foundation

class Day5A: DayCommand {
    typealias Input = (rules: [(Int, Int)], updates: [[Int]])
    typealias Output = Int
    
    required init() { /**/ }
    
    func parseInput(_ input: String) throws -> Input {
        let input = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .split(separator: "", maxSplits: 1)
        
        let firstPart = try input[0].map {
            let numbers = try $0.split(separator: "|", maxSplits: 1).map { try Int($0).unwrapped }
            guard numbers.count == 2 else { throw "invalid input" }
            return (numbers[0], numbers[1])
        }
        
        let secondPart = try input[1].map { try $0.components(separatedBy: ",").map { try Int($0).unwrapped } }
        
        return (firstPart, secondPart)
    }
    
    func run(_ input: Input) throws -> Output {
        let ordering = Dictionary(grouping: input.rules) { $0.0 }.mapValues { Set($0.map(\.1)) }
        
        return input.updates.filter { update in
            let mappings = Dictionary(uniqueKeysWithValues: update.enumerated().map { ($1, $0) })
            return update.enumerated().allSatisfy { (key, value) in
                ordering[value]?.allSatisfy { key < mappings[$0] ?? Int.max } ?? true
            }
        }
        .map { $0[$0.count / 2] }
        .reduce(0, +)
    }
}

class Day5B: Day5A {
    override func run(_ input: Input) throws -> Output {
        let ordering = Dictionary(grouping: input.rules) { $0.0 }.mapValues { Set($0.map(\.1)) }
        
        return input.updates.filter { update in
            let mappings = Dictionary(uniqueKeysWithValues: update.enumerated().map { ($1, $0) })
            return !update.enumerated().allSatisfy { (key, value) in
                ordering[value]?.allSatisfy { key < mappings[$0] ?? Int.max } ?? true
            }
        }
        .map { $0.sorted { l, r in ordering[l]?.contains(r) ?? false } }
        .map { $0[$0.count / 2] }
        .reduce(0, +)
    }
}
