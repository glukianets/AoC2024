import Foundation

class Day1A: DayCommand {
    typealias Input = [(Int, Int)]
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map {
            let numbers = $0.components(separatedBy: .whitespaces).compactMap { Int($0)  }
            guard numbers.count == 2 else { throw "failed to parse \(numbers)" }
            return (numbers[0], numbers[1])
        }
    }

    func serializeOutput(_ output: Output) throws -> String {
        "\(output)"
    }

    func run(_ input: Input) throws -> Output {
        zip(input.map(\.0).sorted(), input.map(\.1).sorted()).map { abs($0 - $1) }.reduce(0, +)
    }
}

class Day1B: Day1A {
    typealias Input = [(Int, Int)]
    typealias Output = Int

    override func run(_ input: Input) throws -> Output {
        let l = input.map(\.0)
        let r = Dictionary(input.map(\.1).map { ($0, 1) }, uniquingKeysWith: +)
        return l.map { $0 * r[$0, default: 0] }.reduce(0, +)
    }
}
