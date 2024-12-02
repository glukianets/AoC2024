import Foundation
import Testing
@testable import AdventOfCode2024

final class AdventOfCode2021Tests {
    @Test(arguments: AdventOfCode.subcommands)
    func testDay(_ commandType: any DayCommand.Type) async throws {
        let command = commandType.init()
        let commandName = String(describing: commandType)
        
        let rawInput = try testData(fileName: commandName, extension: "input")
            ?? testData(fileName: String(commandName.dropLast(1)), extension: "input")
        
        let input = rawInput?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let input else { throw "Input not found for \(commandName)" }
   
        let rawOutput = try command.run(stringInput: input)
        let output = rawOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let rawExpectedOutput = try testData(fileName: commandName, extension: "output") else {
            Issue.record("No expected result for \(commandName) to compare; actual result was \(output)")
            return
        }
        
        let expectedOutput = rawExpectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)

        try #require(output == expectedOutput)
    }
    
    @Test
    func testParticular() async throws {
        try await self.testDay(Day0.self)
    }
    
    private func testData(fileName: String, extension: String? = nil) throws -> String? {
        try Bundle.module.url(forResource: fileName, withExtension: `extension`, subdirectory: "TestData").flatMap {
            try String(data: try Data(contentsOf: $0), encoding: .utf8).unwrapped
        }
    }
}
