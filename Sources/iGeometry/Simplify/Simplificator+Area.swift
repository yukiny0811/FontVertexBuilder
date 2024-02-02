//
//  Simplificator+Area.swift
//  
//
//  Created by Nail Sharipov on 19.09.2022.
//

extension Simplificator {
    
    
    func isSmallArea(points: [IntPoint], isClockWise: Bool) -> Bool {
        let s = points.area
        let area = isClockWise ? s : -s
        
        return area < minArea
    }
}
