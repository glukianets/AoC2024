import Foundation

extension String: Error {}

extension Collection where Index: Strideable {
    func map<R>(
        windowOfSize w: Index.Stride,
        stridingBy s: Index.Stride? = nil,
        _ transform: (SubSequence) -> R
    ) -> [R] {
        stride(from: self.startIndex, to: self.endIndex.advanced(by: 1 - w), by: s ?? w)
            .map { transform(self[$0..<($0.advanced(by: w))]) }
    }
}

extension Optional {
    var unwrapped: Wrapped {
        get throws {
            guard case let .some(wrapped) = self else {
                throw "Failed to unwrap optional of type \(Self.self)"
            }
            return wrapped
        }
    }
}


precedencegroup PowerPrecedence {
    higherThan: MultiplicationPrecedence
}

infix operator ^^: PowerPrecedence

func ^^<T: BinaryInteger>(radix: T, power: T) -> T {
    T(pow(Double(radix), Double(power)))
}

func *<C1, C2>(_ lhs: C1, _ rhs: C2) -> AnyCollection<(C1.Element, C2.Element)>
where C1: Collection, C2: Collection {
    AnyCollection(lhs.lazy.flatMap { l in rhs.lazy.map { r in (l, r) } })
}

extension ClosedRange {
    func intersection(with other: ClosedRange) -> ClosedRange? {
        let lowerBound = Swift.max(self.lowerBound, other.lowerBound)
        let upperBound = Swift.min(self.upperBound, other.upperBound)
        return lowerBound <= upperBound ? lowerBound...upperBound : nil
    }
}

func memoized<I: Hashable, O>(_ f: @escaping (I) throws -> O) -> (I) throws -> O {
    var cache: [I: O] = [:]
    return { input in
        if let output = cache[input] {
            return output
        } else {
            let output = try f(input)
            cache[input] = output
            return output
        }
    }
}

func memoized<I: Hashable, O>(_ f: @escaping (I) -> O) -> (I) -> O {
    let f = memoized(f as (I) throws -> O)
    return { try! f($0) }
}
