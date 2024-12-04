import Foundation

class Day3A: DayCommand {
    typealias Input = [Mul]
    typealias Output = Int
    
    struct Mul {
        let lhs: Int, rhs: Int
    }
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let regex = /mul\((\d+),(\d+)\)/
        return try input.matches(of: regex).map { match in
            try Mul(lhs: Int(match.output.1).unwrapped, rhs: Int(match.output.2).unwrapped)
        }
    }

    func serializeOutput(_ output: Output) throws -> String {
        "\(output)"
    }

    func run(_ input: Input) throws -> Output {
        input.reduce(0) { $0 + $1.lhs * $1.rhs }
    }
}

class Day3B: DayCommand {
    typealias Input = [Instruction]
    typealias Output = Int
    
    enum Instruction {
        case mul(lhs: Int, rhs: Int)
        case `do`
        case dont
    }
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let regex = /(do)\(\)|(don\'t)\(\)|mul\((\d+),(\d+)\)/
        
        return try input.matches(of: regex).map { match -> Instruction in
            switch match.output {
            case (_, .some, nil, nil, nil):
                return Instruction.do
            case (_, nil, .some, nil, nil):
                return Instruction.dont
            case let (_, nil, nil, lhs?, rhs?):
                return try Instruction.mul(lhs: Int(lhs).unwrapped, rhs: Int(rhs).unwrapped)
            default:
                fatalError("?")
            }
        }
    }

    func serializeOutput(_ output: Output) throws -> String {
        "\(output)"
    }

    func run(_ input: Input) throws -> Output {
        var result = 0
        var isEnabled = true
        
        for command in input {
            switch command {
            case .do:
                isEnabled = true
            case .dont:
                isEnabled = false
            case let .mul(lhs: lhs, rhs: rhs) where isEnabled:
                result += lhs * rhs
            default:
                break
            }
        }
        
        return result
    }
}
