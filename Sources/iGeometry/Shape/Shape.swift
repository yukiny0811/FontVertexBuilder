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
    
    public var hull: [f2]
    public var holes: [[f2]]
    
    
    public init(shape: IntShape, iGeom: IntGeom = .defGeom) {
        self.hull = iGeom.float(points: shape.hull)
        self.holes = iGeom.float(paths: shape.holes)
    }
    
    
    public init(hull: [f2], holes: [[f2]]) {
        self.hull = hull
        self.holes = holes
    }
}
