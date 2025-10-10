//
//  Simplificator+Angle.swift
//  
//
//  Created by Nail Sharipov on 15.09.2022.
//

extension Simplificator {
    
    public enum Direction {
        case colinear
        case abDot
        case none
    }
    
    
    func filterByAngle(path: inout PathList<IntPoint>) -> Bool {
        let count = path.count
        
        var ea = path.first
        var eb = path.next(ea.index)
        var ec = path.next(eb.index)
        
        var isLastModified = false
        var i = path.count
        
        while (i >= 0 || isLastModified) && ea.index != .empty && eb.index != .empty && ec.index != .empty {
            isLastModified = false
            
            let a = ea.value
            let b = eb.value
            let c = ec.value
            
            let res = validate(v0: a, v1: c, center: b)
            switch res {
            case .colinear:
                path.remove(eb.index)
                isLastModified = true
                
                eb = ec
                ec = path.next(ec.index)
            case .abDot:
                path.remove(eb.index)
                path.remove(ec.index)
                isLastModified = true
                
                eb = ea
                ea = path.prev(eb.index)
                ec = path.next(eb.index)
            case .none:
                ea = eb
                eb = ec
                ec = path.next(ec.index)
            }
            
            
            i -= 1
        }
        
        return count != path.count
    }
    
    
    func validate(v0 a: IntPoint, v1 b: IntPoint, center c: IntPoint) -> Direction {
        guard a != b else {
            return .abDot
        }
        
        let dy0 = a.y - c.y
        let dx0 = a.x - c.x

        let dy1 = b.y - c.y
        let dx1 = b.x - c.x
        
        let m0 = dx0 * dx0 + dy0 * dy0
        let m1 = dx1 * dx1 + dy1 * dy1
        
        let ab = (Double(m0) * Double(m1)).squareRoot()
        let axb = Double(dx0 * dx1 + dy0 * dy1)
        let aCos = abs(axb / ab)
        
        if aCos > maxCos {
            return .colinear
        } else {
            return .none
        }
    }

}
