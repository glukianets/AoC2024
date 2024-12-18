import Foundation

class Day17A: DayCommand {
    typealias Input = (registers: Registers, program: [UInt8])
    typealias Output = String
    
    enum OpCode: UInt8 {
        case adv = 0b000 // a = a / 2^combo
        case bxl = 0b001 // b = b xor literal
        case bst = 0b010 // b = combpo % 8
        case jnz = 0b011 // if a != 0 jmp literal // no +2
        case bxc = 0b100 // b = b ^ c
        case out = 0b101 // print(combo % 8)
        case bdv = 0b110 // b = a / 2^combo
        case cdv = 0b111 // c = a / 2^combo
    }
    
    enum Register: UInt8 {
        case a = 4
        case b
        case c
    }
    
    typealias Literal = Int
    
    enum Operand: RawRepresentable {
        case literal(UInt8)
        case register(Register)
        
        var rawValue: UInt8 {
            switch self {
            case .literal(let literal): literal
            case .register(let register): register.rawValue
            }
        }
        
        init(rawValue: UInt8) {
            self = Register(rawValue: rawValue).map(Self.register(_:)) ?? .literal(rawValue)
        }
    }
    
    struct Registers {
        nonisolated(unsafe) static let allKeyPaths: [WritableKeyPath<Self, Int>] = [\.a, \.b, \.c]
        var a = 0, b = 0, c = 0
        
        init(_ values: some Sequence<(Register, Literal)>) {
            for (register, value) in values {
                self[register] = value
            }
        }
        
        subscript(_ register: Register) -> Literal {
            get {
                withUnsafePointer(to: self) {
                    $0.withMemoryRebound(to: Int.self, capacity: 4) { ptr in
                        ptr[Int(register.rawValue - 4)]
                    }
                }
            }
            
            set {
                withUnsafeMutablePointer(to: &self) {
                    $0.withMemoryRebound(to: Int.self, capacity: 3) { ptr in
                        ptr[Int(register.rawValue - 4)] = newValue
                    }
                }
            }
        }
        
        subscript(_ register: Operand) -> Literal {
            get {
                switch register {
                case .literal(let value): Literal(value)
                case .register(let register): self[register]
                }
            }
            set {
                guard case .register(let register) = register else { return }
                self[register] = newValue
            }
        }

    }
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let halves = input.split(separator: "\n\n")
        guard let former = halves.first, let latter = halves.last, halves.count == 2 else { throw "Invalid input" }

        let registerRegex = /^Register (\w+):\s*(-?\d+)$/
        let programRegex = /^Program:\s*((?:-?\d+)(?:,\s*(?:-?\d+))*)$/
        
        let registers = try Registers(former.components(separatedBy: .newlines)
            .map { try $0.wholeMatch(of: registerRegex).unwrapped }
            .map { try (Register(rawValue: $0.output.1.first.unwrapped.asciiValue.unwrapped - 61).unwrapped, Int($0.output.2).unwrapped) }
        )
        
        let program = try (
            latter.wholeMatch(of: programRegex)?.output.1
            .components(separatedBy: ",")
            .map { try UInt8($0).unwrapped }
        ).unwrapped
        
        
        return (registers, program)

    }
    
    @_optimize(speed)
    @inline(__always)
    func simulate(program: [UInt8], ip: inout Int, registers: inout Registers, output: inout [Int]) throws {
        var operand: Operand { Operand(rawValue: program[ip + 1]) }
        var literal: Literal { Literal(program[ip + 1]) }

        while ip < program.endIndex {
            switch OpCode(rawValue: program[ip]) {
            case .adv:
                registers.a = registers.a / (1 << registers[operand])
            case .bxl:
                registers.b ^= Int(literal)
            case .bst:
                registers.b = registers[operand] % 8
            case .jnz:
                ip = registers.a == 0 ? ip : literal - 2
            case .bxc:
                registers.b ^= registers.c
            case .out:
                output.append(registers[operand] % 8)
            case .bdv:
                registers.b = registers.a / (1 << registers[operand])
            case .cdv:
                registers.c = registers.a / (1 << registers[operand])
            case nil:
                fatalError()
            }
            ip += 2
        }
    }

    @_optimize(speed)
    func run(_ input: Input) async throws -> Output {
        let program = input.program
        var registers = input.registers

        var ip = program.startIndex
        var output: [Literal] = []
        
        try self.simulate(program: program, ip: &ip, registers: &registers, output: &output)
        
        return output.map { "\($0)" }.joined(separator: ",")
    }
}

class Day17B: Day17A {
    @_optimize(speed)
    override func run(_ input: Input) async throws -> Output {
        let program = input.program
        let target = input.program.map { Int($0) }
        
        for a in 0... {
            if a % 1000 == 0 {
                print(".", terminator: "")
            }
            if a % 100000 == 0 {
                print("")
            }

            
            var registers = input.registers
            registers.a = a
            var ip = program.startIndex
            var output: [Literal] = []
            
            try self.simulate(program: program, ip: &ip, registers: &registers, output: &output)
            
            if output == target {
                return "\(a)"
            }
        }
        
        return "?"
    }
}
