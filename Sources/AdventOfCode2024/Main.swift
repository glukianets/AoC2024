import Foundation
import ArgumentParser

@main
struct AdventOfCode: ParsableCommand {
    public static let configuration = CommandConfiguration(
        subcommands: [
            Day0.self,
        ]
    )
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

extension DayCommand {
    func run() throws {
        guard let dataInput = try FileHandle.standardInput.readToEnd() else {
            throw "Failed to retrieve input data. Make sure you're providing data in stdin"
        }
        guard let stringInput = String(data: dataInput, encoding: .utf8) else {
            throw "Failed to parse input. Make sure you're providing correct ut8 string data."
        }
        let input = try self.parseInput(stringInput)
        let output = try self.run(input)
        let outputString = try self.serializeOutput(output) + "\n"
        guard let outputData = outputString.data(using: .utf8) else {
            throw "Failed to serialize output data"
        }
        try FileHandle.standardOutput.write(contentsOf: outputData)
    }
}
