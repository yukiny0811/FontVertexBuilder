//
//  Simplificator.swift
//  
//
//  Created by Nail Sharipov on 15.09.2022.
//

import Darwin

public struct Simplificator {
    
    public static let plain = Simplificator(strategy: .linear, minDistance: 10, minAngle: 0.1)
    
    public struct Result {
        public let isModified: Bool
        public let points: [IntPoint]
        
        
        public init(isModified: Bool, points: [IntPoint]) {
            self.isModified = isModified
            self.points = points
        }
    }
    
    public enum Strategy {
        case no
        case linear
    }
    
    public let strategy: Strategy
    public let minDistance: Int64
    public let minArea: Int64
    public let maxCos: Double

    
    public init(strategy: Strategy, minDistance: Int64, minArea: Int64, minAngle grad: Double) {
        self.strategy = strategy
        self.minDistance = minDistance
        self.minArea = minArea
        self.maxCos = cos(grad * .pi / 180)
    }

    
    public init(strategy: Strategy = .linear, minDistance: Int64 = 10, minAngle grad: Double = 0.1) {
        self.strategy = strategy
        self.minDistance = minDistance
        self.minArea = minDistance * minDistance
        self.maxCos = cos(grad * .pi / 180)
    }

    
    public func simplify(points: [IntPoint], isClockWise: Bool) -> Result {
        switch self.strategy {
            case .linear:
            return self.linear(points: points, isClockWise: isClockWise)
        case .no:
#if DEBUG
            assertionFailure("Simplificator is No, are not allowed at production")
            return Result(isModified: false, points: [])
#else
            fatalError("Simplificator is No, are not allowed at production")
#endif
        }
    }
}
