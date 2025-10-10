//
//  Circle.swift
//  iGeometry
//
//  Created by Nail Sharipov on 13.02.2020.
//  Copyright © 2020 iShape. All rights reserved.
//

import SimpleSimdSwift

public struct Circle {
    
    public let center: simd_double2
    public let radius: Double

    public init(center: simd_double2, radius: Double) {
        self.center = center
        self.radius = radius
    }
}
