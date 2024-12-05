import Foundation

class Day4A: DayCommand {
    typealias Input = [[UInt8]]
    typealias Output = Int
    
    required init() { /**/ }
    
    func parseInput(_ input: String) throws -> Input {
        let input = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let max = input.lazy.map { $0.count }.max() ?? 0
        return input.map { $0.padding(toLength: max, withPad: "\0", startingAt: 0).map { $0.asciiValue ?? 0 } }
    }

    func run(_ input: Input) throws -> Output {
        func find(at position: (x: Int, y: Int), toward direction: (x: Int, y: Int), subject: some StringProtocol) -> Bool {
            guard let first = subject.first else { return true }
            guard let value = first.asciiValue else { return false }
            guard input.indices ~= position.y && input[position.y].indices ~= position.x else { return false }
            guard input[position.x][position.y] == value else { return false }
            return find(at: (position.x + direction.x, position.y + direction.y), toward: direction, subject: subject.dropFirst())
        }
        
        let indices = input.indices.flatMap { y in input[y].indices.map { x in (x, y) } }
        let directions = (-1...1).flatMap { y in (-1...1).map { x in (x, y) } }.filter { $0 != (0, 0) }
        
        return indices.lazy.map { position in
            directions.count { direction in
                find(at: position, toward: direction, subject: "XMAS")
            }
        }.reduce(0, +)
    }
}

class Day4B: Day4A {
    override func run(_ input: Input) throws -> Output {
        let indices: [(x: Int, y: Int)] = input.indices.dropFirst().dropLast().flatMap { y in
            input[y].indices.dropFirst().dropLast().map { x in (x, y) }
        }
        let vicinity: [(x: Int, y: Int)] = [(-1, -1), (1, -1), (1, 1), (-1, 1)]
        
        return indices.count { position in
            guard input[position.y][position.x] == 65 /*A*/ else { return false }
            let letters = vicinity.map { direction in input[position.y + direction.y][position.x + direction.x] }
            return letters.allSatisfy { $0 == 77 /*M*/ || $0 == 83 /*S*/ } && letters[0] != letters[2] && letters[1] != letters[3]
        }
    }
}
