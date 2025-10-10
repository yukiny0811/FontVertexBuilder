//
//  Shape.swift
//  iGeometry
//
//  Created by Nail Sharipov on 23/09/2019.
//  Copyright © 2019 iShape. All rights reserved.
//

import SimpleSimdSwift

public struct Shape {
    
    public static let empty = Shape(hull: [], holes: [])
    
    public var hull: [simd_double2]
    public var holes: [[simd_double2]]

    
    public init(shape: IntShape, iGeom: IntGeom = .defGeom) {
        self.hull = iGeom.float(points: shape.hull)
        self.holes = iGeom.float(paths: shape.holes)
    }
    
    
    public init(hull: [simd_double2], holes: [[simd_double2]]) {
        self.hull = hull
        self.holes = holes
    }
}
