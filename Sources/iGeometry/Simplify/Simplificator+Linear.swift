//
//  Simplificator+Linear.swift
//  
//
//  Created by Nail Sharipov on 15.09.2022.
//

extension Simplificator {
    
    
    func linear(points: [IntPoint], isClockWise: Bool) -> Result {
        guard points.count > 2 else {
            return .init(isModified: true, points: [])
        }
        
        var path = PathList(array: points, empty: .zero)
        let count = path.count
        var filterDist = true
        var filterAngl = true
        
        while filterDist || filterAngl {
            
            if filterDist {
                let isModified = self.filterLinearByDistance(path: &path)
                filterAngl = filterAngl || isModified
                filterDist = false
                
                guard path.count > 2 else {
                    return .init(isModified: true, points: [])
                }
            }

            if filterAngl {
                filterDist = self.filterByAngle(path: &path)
                filterAngl = false
                
                guard path.count > 2 else {
                    return .init(isModified: true, points: [])
                }
            }
        }

        let isModified = count != path.count
        
        if isModified {
            let result = path.sequence
            if self.isSmallArea(points: result, isClockWise: isClockWise) {
                return .init(isModified: true, points: [])
            } else {
                return .init(isModified: true, points: result)
            }
        } else {
            if self.isSmallArea(points: points, isClockWise: isClockWise) {
                return .init(isModified: true, points: [])
            } else {
                return .init(isModified: false, points: points)
            }
        }
    }
    
    
    func filterLinearByDistance(path: inout PathList<IntPoint>) -> Bool {
        let count = path.count
        
        var ea = path.first
        var eb = path.next(ea.index)
        
        let sqrMinDist = minDistance * minDistance
        var isLastModified = false
        var i = path.count
        
        while (i >= 0 || isLastModified) && ea.index != .empty && eb.index != .empty {
            
            isLastModified = false
            
            let a = ea.value
            let b = eb.value
            
            let dx = b.x - a.x
            let dy = b.y - a.y
            let sqrDist = dx * dx + dy * dy
            
            if sqrDist < sqrMinDist {
                path.remove(eb.index)
                eb = path.next(ea.index)
                isLastModified = true
            } else {
                ea = eb
                eb = path.next(eb.index)
            }
            
            i -= 1
        }
        
        return count != path.count
    }
}
