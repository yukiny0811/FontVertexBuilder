//
//  IntGeom.swift
//  iGeometry
//
//  Created by Nail Sharipov on 23/09/2019.
//  Copyright © 2019 iShape. All rights reserved.
//

import SimpleSimdSwift

public struct IntGeom {
    
    public static let defGeom = IntGeom()
    
    public static let maxBits = 31
    public let scale: Double
    public let invertScale: Double
    public let sqrInvertScale: Double

    
    public init(scale: Double = 10000) {
        self.scale = scale
        self.invertScale = 1 / scale
        self.sqrInvertScale = 1 / scale / scale
    }
    
    public func int(points: [simd_double2]) -> [IntPoint] {
        let n = points.count
        var array = Array<IntPoint>(repeating: .zero, count: n)
        var i = 0
        while i < n {
            let point = points[i]
            array[i] = IntPoint(x: Int64((point.x * scale).rounded(.toNearestOrAwayFromZero)), y: Int64((point.y * scale).rounded(.toNearestOrAwayFromZero)))
            i &+= 1
        }
        return array
    }
    
    
    public func int(paths: [[simd_double2]]) -> [[IntPoint]] {
        let n = paths.count
        var array = [[IntPoint]]()
        array.reserveCapacity(n)
        var i = 0
        while i < n {
            array.append(self.int(points: paths[i]))
            i &+= 1
        }
        return array
    }
    
    
    public func float(int: Int64) -> Double {
        Double(int) * invertScale
    }
    
    
    public func sqrFloat(int: Int64) -> Double {
        Double(int) * sqrInvertScale
    }
    
    
    public func float(point: IntPoint) -> simd_double2 {
        simd_double2(x: Double(point.x) * invertScale, y: Double(point.y) * invertScale)
    }
    
    
    public func float(points: [IntPoint]) -> [simd_double2] {
        let n = points.count
        var array = Array<simd_double2>(repeating: .zero, count: n)
        var i = 0
        while i < n {
            let point = points[i]
            array[i] = simd_double2(x: Double(point.x) * invertScale, y: Double(point.y) * invertScale)
            i &+= 1
        }
        return array
    }
    
    
    public func float(paths: [[IntPoint]]) -> [[simd_double2]] {
        let n = paths.count
        var array = [[simd_double2]]()
        array.reserveCapacity(n)
        var i = 0
        while i < n {
            array.append(self.float(points: paths[i]))
            i &+= 1
        }
        return array
    }
}
