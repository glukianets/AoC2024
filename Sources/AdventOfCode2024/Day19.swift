import Foundation
import Algorithms

class Day19A: DayCommand {
    typealias Input = (patterns: [String], designs: [String])
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let halves = input.split(separator: "\n\n")
        guard let former = halves.first, let latter = halves.last, halves.count == 2 else { throw "Invalid input" }

        let patterns = former.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
        let designs = latter.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }

        return (patterns.sorted().reversed(), designs)
    }

    func run(_ input: Input) throws -> Output {
        func canAssemble(_ design: some StringProtocol, patterns: [String]) -> Bool {
            if design.isEmpty { return true }
            return patterns
                .filter { design.hasPrefix($0) }
                .contains { canAssemble(design.dropFirst($0.count), patterns: patterns) }
        }
        
        let patterns = input.patterns.filter { it in !canAssemble(it, patterns: input.patterns.filter { $0 != it }) }
        
        return input.designs.count { canAssemble($0, patterns: patterns) }
    }
}

class Day19B: Day19A {
    typealias Input = (patterns: [String], designs: [String])
    typealias Output = Int

    override func run(_ input: Input) throws -> Output {
        var cache: [Substring: Int] = ["": 1]
        
        func assemble(_ design: Substring) -> Int {
            if let result = cache[design] { return result }

            let result = input.patterns
                .filter { design.hasPrefix($0) }
                .map { assemble(design.dropFirst($0.count)) }
                .reduce(0, +)
            
            precondition(cache.updateValue(result, forKey: design) == nil)
            return result
        }
        
        return input.designs.lazy.map { assemble($0[...]) }.reduce(0, +)
    }
}
