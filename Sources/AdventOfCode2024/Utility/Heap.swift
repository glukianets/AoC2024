import Foundation

public struct Heap<Element> {
    public typealias Index = Int
    
    public var property: ((Element, Element) -> Bool)? {
        didSet {
            self.heapify()
        }
    }

    private var elements: [Element]

    public init(by property: @escaping (Element, Element) -> Bool) {
        self.elements = []
        self.property = property
    }
    
    public init<S>(_ sequence: S, by property: @escaping (Element, Element) -> Bool)
    where S: Sequence, S.Element == Self.Element {
        self.elements = Array(sequence)
        self.property = property
        self.heapify()
    }
    
    public mutating func insert(_ element: Element) {
        self.elements.append(element)
        self.swim(self.elements.index(before: self.elements.endIndex))
    }

    @discardableResult public mutating func remove(at index: Index) -> Element? {
        guard let index = self.check(index: index) else { return nil }
        self.elements.swapAt(index, self.elements.index(before: self.elements.endIndex))
        let element = self.elements.removeLast()
        guard let index = self.check(index: index) else { return element }
        self.sink(index)
        self.swim(index)
        return element
    }
}

private extension Heap {
    mutating func heapify() {
        guard let property = self.property else { return }
        self.elements.sort(by: property)
    }
    
    mutating func swim(_ child: inout Index) {
        self.sift(&child) { [self] index in
            if let parent = self.parent(of: index), self.element(at: index, preceeds: parent) {
                return parent
            } else {
                return nil
            }
        }
    }
    
    @inline(__always)
    mutating func swim(_ child: Index) {
        var index = child
        self.swim(&index)
    }
    
    mutating func sink(_ parent: inout Index) {
        self.sift(&parent) { [self] index in
            if let left = self.leftChild(of: index), self.element(at: left, preceeds: index) {
                return left
            } else if let right = self.rightChild(of: index), self.element(at: right, preceeds: index) {
                return right
            } else {
                return nil
            }
        }
    }
    
    @inline(__always)
    mutating func sink(_ parent: Index) {
        var index = parent
        self.sink(&index)
    }
    
    @inline(__always)
    mutating func sift(_ current: inout Index, select: (Index) -> Index?) {
        while let next = select(current) {
            self.elements.swapAt(current, next)
            current = next
        }
    }

    @inline(__always)
    func parent(of index: Index) -> Index? {
        self.check(index: (index - 1) / 2)
    }

    @inline(__always)
    func leftChild(of index: Index) -> Index? {
        self.check(index: 2 * index + 1)
    }

    @inline(__always)
    func rightChild(of index: Index) -> Index? {
        self.check(index: 2 * index + 2)
    }
    
    @inline(__always)
    func check(index: Index) -> Index? {
        self.indices.contains(index) ? index : nil
    }
    
    @inline(__always)
    func element(at lhs: Index, preceeds rhs: Index) -> Bool {
        self.property?(self.elements[lhs], self.elements[rhs]) ?? false
    }
    
    @inline(__always)
    func element(at lhs: Index, preceedsElement rhs: Element) -> Bool {
        self.property?(self.elements[lhs], rhs) ?? false
    }
}

extension Heap: MutableCollection {
    public var startIndex: Index {
        self.elements.startIndex
    }
    
    public var endIndex: Index {
        self.elements.endIndex
    }
    
    public func index(after i: Int) -> Int {
        self.elements.index(after: i)
    }
    
    public func distance(from start: Int, to end: Int) -> Int {
        self.elements.distance(from: start, to: end)
    }
    
    public var indices: Range<Index> {
        self.elements.indices
    }
    
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        self.elements.index(i, offsetBy: distance)
    }
    
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        self.elements.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    public func formIndex(after i: inout Int) {
        self.elements.formIndex(after: &i)
    }
    
    public subscript(position: Int) -> Element {
        get {
            self.elements[position]
        }
        
        set {
            if self.element(at: position, preceedsElement: newValue) {
                self.elements[position] = newValue
                self.sink(position)
            } else {
                self.elements[position] = newValue
                self.swim(position)
            }
        }
    }
    
    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            self.elements[bounds]
        }
        set {
            self.replaceSubrange(bounds, with: newValue)
        }
    }
}

extension Heap: RangeReplaceableCollection {
    public init() {
        self.elements = []
        self.property = nil
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
    where C: Collection, C.Element == Self.Element {
        for index in subrange {
            self.remove(at: index)
        }
        for element in newElements {
            self.insert(element)
        }
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        self.elements.reserveCapacity(n)
    }
}

public extension Heap where Element: Comparable {
    init() {
        self.init(by: <)
    }
}
