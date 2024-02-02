//
//  Circle.swift
//  iGeometry
//
//  Created by Nail Sharipov on 13.02.2020.
//  Copyright © 2020 iShape. All rights reserved.
//

import SimpleSimdSwift

public struct Circle {
    
    public let center: f2
    public let radius: Float
    
    public init(center: f2, radius: Float) {
        self.center = center
        self.radius = radius
    }
}
