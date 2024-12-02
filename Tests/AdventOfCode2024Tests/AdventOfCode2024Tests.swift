import XCTest
@testable import AdventOfCode2024

final class AdventOfCode2021Tests: XCTestCase {
    static func run<Day: DayCommand>(_ day: Day, input string: String) throws -> String {
        let input = try day.parseInput(string)
        let output = try day.run(input)
        let outputString = try day.serializeOutput(output)
        return outputString
    }

    func testDay0() throws {
        let input = """
        """

        XCTAssertEqual("", try Day0().run(input))
    }
}

