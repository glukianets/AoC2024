import Foundation
import Testing
@testable import AdventOfCode2024

final class AdventOfCode2021Tests {
    @Test(arguments: AdventOfCode.subcommands)
    func testDay(_ commandType: any DayCommand.Type) async throws {
        let command = commandType.init()
        let commandName = String(describing: commandType)
        
        let input = try testData(fileName: commandName, extension: "input")
            ?? testData(fileName: String(commandName.dropLast(1)), extension: "input")
        
        guard let input else { throw "Input not found for \(commandName)" }
   
        let output = try command.run(stringInput: input)
        
        guard let expectedOutput = try testData(fileName: commandName, extension: "output") else {
            Issue.record("No expected result for \(commandName) to compare; actual result was \(output)")
            return
        }

        try #require(output == expectedOutput)
    }
    
    @Test
    func testParticular() async throws {
        try await self.testDay(Day1A.self)
    }
    
    private func testData(fileName: String, extension: String? = nil) throws -> String? {
        try Bundle.module.url(forResource: fileName, withExtension: `extension`, subdirectory: "TestData").flatMap {
            try String(data: try Data(contentsOf: $0), encoding: .utf8).unwrapped
        }
    }
}
