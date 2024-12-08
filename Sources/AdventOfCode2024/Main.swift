import Foundation
import ArgumentParser

@main
struct AdventOfCode: ParsableCommand {
    public static let subcommands: [any DayCommand.Type] = [
        Day1A.self,
        Day1B.self,
        Day2A.self,
        Day2B.self,
        Day3A.self,
        Day3B.self,
        Day4A.self,
        Day4B.self,
        Day5A.self,
        Day5B.self,
        Day6A.self,
        Day6B.self,
    ]
    
    public static let configuration = CommandConfiguration(subcommands: Self.subcommands)
}

protocol DayCommand: ParsableCommand {
    associatedtype Output
    associatedtype Input

    func run(_ input: Input) throws -> Output

    func parseInput(_ input: String) throws -> Input
    func serializeOutput(_ output: Output) throws -> String
}

extension DayCommand where Input == String {
    func parseInput(_ input: String) throws -> Input {
        input
    }
}

extension DayCommand where Output == String {
    func serializeOutput(_ output: Output) throws -> String {
        output
    }
}

extension DayCommand where Output == Int {
    func serializeOutput(_ output: Output) throws -> String {
        "\(output)"
    }
}


extension DayCommand {
    func run(stringInput: String) throws -> String {
        let input = try self.parseInput(stringInput)
        let output = try self.run(input)
        let outputString = try self.serializeOutput(output)
        return outputString
    }
    
    func run(in: FileHandle, out: FileHandle) throws {
        guard let dataInput = try `in`.readToEnd() else {
            throw "Failed to retrieve input data. Make sure you're providing data in stdin"
        }
        guard let stringInput = String(data: dataInput, encoding: .utf8) else {
            throw "Failed to parse input. Make sure you're providing correct ut8 string data."
        }
        
        let outputString = try self.run(stringInput: stringInput)
        
        guard let outputData = outputString.data(using: .utf8) else {
            throw "Failed to serialize output data"
        }
        try `out`.write(contentsOf: outputData)

    }
 
    func run() throws {
        try self.run(in: FileHandle.standardInput, out: FileHandle.standardOutput)
    }
}
