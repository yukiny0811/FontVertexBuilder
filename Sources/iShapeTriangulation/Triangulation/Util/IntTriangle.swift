//
//  IntPoint+Triangle.swift
//  iGeometry
//
//  Created by Nail Sharipov on 25.10.2019.
//

import iGeometry

struct IntTriangle {
    
    enum Orientation {
        case clockWise
        case counterClockWise
        case line
    }
    
    
    static func getOrientation(a: IntPoint, b: IntPoint, c: IntPoint) -> Orientation {
        let m0 = (c.y - a.y) * (b.x - a.x)
        let m1 = (b.y - a.y) * (c.x - a.x)
        
        if m0 < m1 {
            return .clockWise
        } else if m0 > m1 {
            return .counterClockWise
        } else {
            return .line
        }
    }
    
    
    static func isNotLine(a: IntPoint, b: IntPoint, c: IntPoint) -> Bool {
        let m0 = (c.y - a.y) * (b.x - a.x)
        let m1 = (b.y - a.y) * (c.x - a.x)
        return m0 != m1
    }
    
    
    static func isCCW(a: IntPoint, b: IntPoint, c: IntPoint) -> Bool {
        let m0 = (c.y - a.y) * (b.x - a.x)
        let m1 = (b.y - a.y) * (c.x - a.x)
        
        return m0 < m1
    }
    
    
    static func isCCW_or_Line(a: IntPoint, b: IntPoint, c: IntPoint) -> Bool {
        let m0 = (c.y - a.y) * (b.x - a.x)
        let m1 = (b.y - a.y) * (c.x - a.x)
        
        return m0 <= m1
    }

}
