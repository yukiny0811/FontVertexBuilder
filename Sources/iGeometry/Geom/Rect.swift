//
//  Rect.swift
//  
//
//  Created by Nail Sharipov on 25.11.2022.
//

public struct Rect {

    public static let empty = Rect(minX: Int64.max, minY: Int64.max, maxX: Int64.min, maxY: Int64.min)
    
    public var minX: Int64
    public var minY: Int64
    public var maxX: Int64
    public var maxY: Int64

    
    public init(minX: Int64, minY: Int64, maxX: Int64, maxY: Int64) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
    
    
    public init(a: IntPoint, b: IntPoint) {
        if b.x > a.x {
            minX = a.x
            maxX = b.x
        } else {
            minX = b.x
            maxX = a.x
        }
        if b.y > a.y {
            minY = a.y
            maxY = b.y
        } else {
            minY = b.y
            maxY = a.y
        }
    }
    
    
    public mutating func assimilate(p: IntPoint) {
        if minX > p.x {
            minX = p.x
        }
    
        if minY > p.y {
            minY = p.y
        }
    
        if maxX < p.x {
            maxX = p.x
        }
    
        if maxY < p.y {
            maxY = p.y
        }
    }
    
    
    public func isNotIntersecting(a: IntPoint, b: IntPoint) -> Bool {
        a.x < minX && b.x < minX || a.x > maxX && b.x > maxX ||
            a.y < minY && b.y < minY || a.y > maxY && b.y > maxY
    }
    
    
    public func isIntersecting(rect: Rect) -> Bool {
        !(maxX < rect.minX || minX > rect.maxX || maxY < rect.minY || minY > rect.maxY)
    }
    
    
    public func isInside(rect: Rect) -> Bool {
        maxX >= rect.maxX && minX <= rect.minX && maxY >= rect.maxY && minY <= rect.minY
    }
   
    
    public func isContain(_ point: IntPoint) -> Bool {
        minX <= point.x && point.x <= maxX && minY <= point.y && point.y <= maxY
    }
    
}
