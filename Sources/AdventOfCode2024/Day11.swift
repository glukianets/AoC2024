import Foundation
import Algorithms
import Collections

class Day11A: DayCommand {
    typealias Input = [Int]
    typealias Output = Int
    
    struct Entry: Hashable {
        var stone: Int
        var blinks: Int
    }
    
    required init() { /**/ }
   
    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .whitespaces).map { try Int($0).unwrapped }
    }
    
    var stepsCount: Int { 25 }
    
    @_optimize(speed)
    func run(_ input: Input) async throws -> Output {
        var rec: (Entry) -> Int = { _ in 0 }
        rec = memoized(process(_:))
        
        func process(_ stone: Int, _ blinks: Int) -> Int {
            rec(Entry(stone: stone, blinks: blinks))
        }
        
        func process(_ input: Entry) -> Int {
            guard input.blinks > 0 else { return 1 }
            guard input.stone != 0 else { return process(1, input.blinks - 1) }
            
            let dc = ceil(log10(Double(input.stone + 1)))
            if Int(dc.truncatingRemainder(dividingBy: 2)) == 0 {
                return process(input.stone / Int(pow(10, dc / 2)), input.blinks - 1)
                     + process(input.stone % Int(pow(10, dc / 2)), input.blinks - 1)
            } else {
                return process(input.stone * 2024, input.blinks - 1)
            }
        }
        
        return input.map { process($0, self.stepsCount) }.reduce(0, +)
    }
}

class Day11B: Day11A {
    override var stepsCount: Int { 75 }
}
