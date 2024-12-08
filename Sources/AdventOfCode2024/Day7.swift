import Foundation
import Collections

class Day7A: DayCommand {
    typealias Input = [(result: Int, operands: [Int])]
    typealias Output = Int
    
    required init() { /**/ }
   
    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).map {
            let parts = $0.split(separator: ":")
            guard let lhs = parts.first, let rhs = parts.last, parts.count == 2 else { throw "Invalid input" }
            return try (Int(lhs).unwrapped, rhs.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.map {
                try Int($0.trimmingCharacters(in: .whitespaces)).unwrapped
            })
        }
    }
    
    func run(_ input: Input) throws -> Output {
        func allPossibleResults(head: Int, tail: some Sequence<Int>) -> some Sequence<Int> {
            guard let next = tail.first(where: { _ in true }) else { return AnySequence([head]) }
            return AnySequence([
                allPossibleResults(head: head + next, tail: tail.dropFirst()),
                allPossibleResults(head: head * next, tail: tail.dropFirst())
            ].joined())
        }
        
        return input.filter { equation in
            allPossibleResults(
                head: equation.operands.first!,
                tail: equation.operands.dropFirst()
            ).contains(equation.result)
        }.map(\.result).reduce(0, +)
    }
}

class Day7B: Day7A {
    typealias Input = [(result: Int, operands: [Int])]
    typealias Output = Int
    
    @_optimize(speed)
    override func run(_ input: Input) throws -> Output {
        let operators: [(Int, Int) -> Int] = [(+), (*), { Int(String($0) + String($1))! }]
        
        func allPossibleResults(head: Int, tail: some Sequence<Int>) -> some Sequence<Int> {
            guard let next = tail.first(where: { _ in true }) else { return AnySequence([head]) }
            
            return AnySequence(operators.lazy.map { op in
                allPossibleResults(head: op(head, next), tail: tail.dropFirst())
            }.flatMap { $0 })
        }
        
        return input.filter { equation in
            allPossibleResults(
                head: equation.operands.first!,
                tail: equation.operands.dropFirst()
            ).contains(equation.result)
        }.map(\.result).reduce(0, +)
    }
}
