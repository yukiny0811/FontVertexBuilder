//
//  Triangle.swift
//  iGeometry
//
//  Created by Nail Sharipov on 13.02.2020.
//  Copyright © 2020 iShape. All rights reserved.
//

import SimpleSimdSwift

public struct Triangle {
    
    public let a: f2
    public let b: f2
    public let c: f2
    
    public init(a: f2, b: f2, c: f2) {
        self.a = a
        self.b = b
        self.c = c
    }
 
    public var area: Float {
        0.5 * (a.x * (c.y - b.y) + b.x * (a.y - c.y) + c.x * (b.y - a.y))
    }
    
    
    public var circumscribedСircle: Circle {
        Triangle.circumscribedСircle(a: a, b: b, c: c)
    }
    
    
    public var inscribedСircle: Circle {
        Triangle.inscribedСircle(a: a, b: b, c: c)
    }
    
    
    public static func circumscribedСircle(a: f2, b: f2, c: f2) -> Circle {
        let d = 2 * (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y))
        let x = ((a.x * a.x + a.y * a.y) * (b.y - c.y) + (b.x * b.x + b.y * b.y) * (c.y - a.y) + (c.x * c.x + c.y * c.y) * (a.y - b.y)) / d
        let y = ((a.x * a.x + a.y * a.y) * (c.x - b.x) + (b.x * b.x + b.y * b.y) * (a.x - c.x) + (c.x * c.x + c.y * c.y) * (b.x - a.x)) / d
        
        let r = ((a.x - x) * (a.x - x) + (a.y - y) * (a.y - y)).squareRoot()
        
        return Circle(center: f2(x: x, y: y), radius: r)
    }
    
    
    public static func inscribedСircle(a: f2, b: f2, c: f2) -> Circle {
        let ABx = a.x - b.x
        let ABy = a.y - b.y
        let AB = (ABx * ABx + ABy * ABy).squareRoot()
        
        let ACx = a.x - c.x
        let ACy = a.y - c.y
        let AC = (ACx * ACx + ACy * ACy).squareRoot()
        
        let BCx = b.x - c.x
        let BCy = b.y - c.y
        let BC = (BCx * BCx + BCy * BCy).squareRoot()
        
        let p = AB + BC + AC
        
        let Ox = (BC * a.x + AC * b.x + AB * c.x) / p
        let Oy = (BC * a.y + AC * b.y + AB * c.y) / p
        
        let r = ((-BC + AC + AB) * (BC - AC + AB) * (BC + AC - AB) / (4 * p)).squareRoot()
        
        return Circle(center: f2(x: Ox, y: Oy), radius: r)
    }
}
