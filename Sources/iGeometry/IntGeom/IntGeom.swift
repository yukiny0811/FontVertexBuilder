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
    public let scale: Float
    public let invertScale: Float
    public let sqrInvertScale: Float
    
    
    public init(scale: Float = 10000) {
        self.scale = scale
        self.invertScale = 1 / scale
        self.sqrInvertScale = 1 / scale / scale
    }
    
    public func int(points: [f2]) -> [IntPoint] {
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
    
    
    public func int(paths: [[f2]]) -> [[IntPoint]] {
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
    
    
    public func float(int: Int64) -> Float {
        Float(int) * invertScale
    }
    
    
    public func sqrFloat(int: Int64) -> Float {
        Float(int) * sqrInvertScale
    }
    
    
    public func float(point: IntPoint) -> f2 {
        f2(x: Float(point.x) * invertScale, y: Float(point.y) * invertScale)
    }
    
    
    public func float(points: [IntPoint]) -> [f2] {
        let n = points.count
        var array = Array<f2>(repeating: .zero, count: n)
        var i = 0
        while i < n {
            let point = points[i]
            array[i] = f2(x: Float(point.x) * invertScale, y: Float(point.y) * invertScale)
            i &+= 1
        }
        return array
    }
    
    
    public func float(paths: [[IntPoint]]) -> [[f2]] {
        let n = paths.count
        var array = [[f2]]()
        array.reserveCapacity(n)
        var i = 0
        while i < n {
            array.append(self.float(points: paths[i]))
            i &+= 1
        }
        return array
    }
}
