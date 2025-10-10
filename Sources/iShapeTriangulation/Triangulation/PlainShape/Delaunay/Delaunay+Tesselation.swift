//
//  Delaunay+Tessellation.swift
//  iGeometry
//
//  Created by Nail Sharipov on 15.07.2020.
//

import Darwin
import iGeometry

extension Delaunay {

    private struct Validator {

        static let sqrMergeCos: Double = {
            let mergeCos = cos(0.8 * Double.pi)
            return mergeCos * mergeCos
        }()
        
        private let maxArea: Double
        private let iGeom: IntGeom
        
        init(iGeom: IntGeom, maxArea: Double) {
            self.iGeom = iGeom
            if maxArea > 0 {
                self.maxArea = 2 * maxArea
            } else {
                self.maxArea = .infinity
            }
        }
        
        static func sqrCos(a: IntPoint, b: IntPoint, c: IntPoint) -> Double {
            let ab = a.sqrDistance(point: b)
            let ca = c.sqrDistance(point: a)
            let bc = b.sqrDistance(point: c)

            guard ab >= bc &+ ca else {
                return 0
            }
            
            let aa = Double(bc)
            let bb = Double(ca)
            let cc = Double(ab)

            let l = aa + bb - cc
            return l * l / (4 * aa * bb)
        }
    }
}

private extension Delaunay.Triangle {
    
    
    var circumscribedCenter: IntPoint {
        let a = self.vertices.a.point
        let b = self.vertices.b.point
        let c = self.vertices.c.point
        let ax = Double(a.x)
        let ay = Double(a.y)
        let bx = Double(b.x)
        let by = Double(b.y)
        let cx = Double(c.x)
        let cy = Double(c.y)
        
        let d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
        let aa = ax * ax + ay * ay
        let bb = bx * bx + by * by
        let cc = cx * cx + cy * cy
        let x = (aa * (by - cy) + bb * (cy - ay) + cc * (ay - by)) / d
        let y = (aa * (cx - bx) + bb * (ax - cx) + cc * (bx - ax)) / d

        return IntPoint(x: Int64(x.rounded(.toNearestOrAwayFromZero)), y: Int64(y.rounded(.toNearestOrAwayFromZero)))
    }

    
    func isContain(p: IntPoint) -> Bool {
        let a = self.vertices.a.point
        let b = self.vertices.b.point
        let c = self.vertices.c.point
        
        let d1 = Delaunay.Triangle.sign(a: p, b: a, c: b)
        let d2 = Delaunay.Triangle.sign(a: p, b: b, c: c)
        let d3 = Delaunay.Triangle.sign(a: p, b: c, c: a)
        
        let has_neg = d1 < 0 || d2 < 0 || d3 < 0
        let has_pos = d1 > 0 || d2 > 0 || d3 > 0
        
        return !(has_neg && has_pos)
    }
    
    
    private static func sign(a: IntPoint, b: IntPoint, c: IntPoint) -> Int64 {
        (a.x &- c.x) &* (b.y &- c.y) &- (b.x &- c.x) &* (a.y &- c.y)
    }
}
