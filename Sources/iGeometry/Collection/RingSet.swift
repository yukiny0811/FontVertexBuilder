//
//  RingSet.swift
//  
//
//  Created by Nail Sharipov on 19.09.2022.
//

public struct RingSet {
    
    struct Node {
        
        
        static let empty = Node(prev: .empty, next: .empty)
        
        
        var prev: Int
        
        
        var next: Int
        
        
        init(prev: Int, next: Int) {
            self.prev = prev
            self.next = next
        }
    }

    
    var buffer: [Node]
    
    
    var firstIndex: Int
    
    
    var count: Int
    
    
    public var isEmpty: Bool { count == 0 }
    
    
    public var first: Int {
        firstIndex
    }

    
    public var sequence: [Int] {
        var result = [Int]()
        result.reserveCapacity(count)
        var index = firstIndex
        var i = 0
        while i < count {
            result.append(index)
            index = buffer[index].next
            i += 1
        }
        return result
    }

    
    public init(size: Int) {
        buffer = [Node](repeating: .empty, count: size)
        count = size
        guard count > 0 else {
            firstIndex = .empty
            return
        }
        
        firstIndex = 0

        for i in 0..<count {
            let prev = (i + count - 1) % count
            let next = (i + 1) % count
            buffer[i] = Node(prev: prev, next: next)
        }
    }
    
    
    public func next(_ element: Int) -> Int {
        assert(element < buffer.count)
        let node = buffer[element]
        return node.next
    }
    
    
    public func prev(_ element: Int) -> Int {
        assert(element < buffer.count)
        let node = buffer[element]
        return node.prev
    }
    
    
    public func contains(_ element: Int) -> Bool {
        assert(element < buffer.count)
        let node = buffer[element]
        let isExist = node.prev != .empty
        return isExist
    }

    
    public mutating func remove(_ element: Int) {
        assert(element < buffer.count)
        let node = buffer[element]
        guard self.contains(element) else { return }
        count -= 1
        
        buffer[element] = .empty

        if count > 0 {
            buffer[node.prev].next = node.next
            buffer[node.next].prev = node.prev
        }
        
        if firstIndex == element {
            firstIndex = node.next
        }
    }

    
    public func forEach(_ body: (Int) -> ()) {
        var index = firstIndex
        var i = 0
        while i < count {
            body(index)
            index = buffer[index].next
            i += 1
        }
    }

    
    public mutating func removeAll() {
        var index = firstIndex
        var i = 0
        while i < count {
            let nextIndex = buffer[index].next
            buffer[index] = .empty
            index = nextIndex
            i += 1
        }
        count = 0
        firstIndex = .empty
    }

}
