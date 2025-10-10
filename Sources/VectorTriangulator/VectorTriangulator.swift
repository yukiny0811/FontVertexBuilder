//
//  File.swift
//  FontVertexBuilder
//
//  Created by Yuki Kuwashima on 2025/10/10.
//


import Foundation
import SimpleSimdSwift
import simd
import CoreGraphics
import CoreText
import iGeometry
import iShapeTriangulation

public enum VectorTriangulator {
    public enum HelperFunctions {
        public static func cubicBezierVelocity2(_ a: simd_double2, _ b: simd_double2, _ c: simd_double2, _ d: simd_double2, _ t: Double) -> simd_double2 {
            let oneMinusT = 1.0 - t
            let oneMinusT2 = oneMinusT * oneMinusT
            let temp1 = 3.0 * oneMinusT2 * (b - a)
            let temp2 = 6.0 * oneMinusT * t * (c - b)
            let temp3 = 3.0 * t * t * (d - c)
            return temp1 + temp2 + temp3
        }
        public static func quadraticBezierVelocity2(_ a: simd_double2, _ b: simd_double2, _ c: simd_double2, _ t: Double) -> simd_double2 {
            let oneMinusT: Double = 1.0 - t
            return 2 * oneMinusT * (b-a) + 2 * t * (c-b)
        }

        // maybe not working? unused.
        public static func isVertexStructureClockwise(data: [simd_double2]) -> Bool {
            var area: Double = 0
            for i in 0..<data.count {
                let i0 = i
                let i1 = (i+1) % data.count
                let a = data[i0]
                let b = data[i1]
                area += (b.x - a.x) * (b.y + a.y)
            }
            return area >= 0 ? false : true
        }
    }
    public enum MainFunctions {
        public static func adaptiveQubicBezierCurve2(
            a: simd_double2,
            b: simd_double2,
            c: simd_double2,
            d: simd_double2,
            aVel: simd_double2,
            bVel: simd_double2,
            cVel: simd_double2,
            angleLimit: Double,
            depth: Int,
            line: inout [simd_double2],
            maxDepth: Int
        ) {
            if depth > maxDepth { return }
            let startMiddleAngle: Double = acos(simd_dot(aVel, bVel))
            let middleEndAngle: Double = acos(simd_dot(bVel, cVel))
            if startMiddleAngle + middleEndAngle > angleLimit {
                let ab = (a+b) * 0.5
                let bc = (b+c) * 0.5
                let cd = (c+d) * 0.5
                let abc = (ab + bc) * 0.5
                let bcd = (bc + cd) * 0.5
                let abcd = (abc + bcd) * 0.5
                let sVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(a, ab, abc, abcd, 0.5))
                Self.adaptiveQubicBezierCurve2(a: a, b: ab, c: abc, d: abcd, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line, maxDepth: maxDepth)
                line.append(abcd)
                let eVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(abcd, bcd, cd, d, 0.5))
                Self.adaptiveQubicBezierCurve2(a: abcd, b: bcd, c: cd, d: d, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line, maxDepth: maxDepth)
            }
        }
        public static func adaptiveQuadraticBezierCurve2(
            a: simd_double2,
            b: simd_double2,
            c: simd_double2,
            aVel: simd_double2,
            bVel: simd_double2,
            cVel: simd_double2,
            angleLimit: Double,
            depth: Int,
            line: inout [simd_double2]
        ) {
            if depth > 8 { return }
            let startMiddleAngle: Double = acos(simd_dot(aVel, bVel))
            let middleEndAngle: Double = acos(simd_dot(bVel, cVel))
            if startMiddleAngle + middleEndAngle > angleLimit {
                let ab = (a+b) * 0.5
                let bc = (b+c) * 0.5
                let abc = (ab + bc) * 0.5
                let sVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(a, ab, abc, 0.5))
                adaptiveQuadraticBezierCurve2(a: a, b: ab, c: abc, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line)
                line.append(abc)
                let eVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(abc, bc, c, 0.5))
                adaptiveQuadraticBezierCurve2(a: abc, b: bc, c: c, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line)
            }
        }
        public static func getGlyphLines(_ glyphPath: CGPath, _ angleLimit: Double, _ distanceLimit: Double, maxDepth: Int) -> [[simd_double2]] {
            var myPath = [simd_double2]()
            var myGlyphPaths = [[simd_double2]]()
            glyphPath.applyWithBlock { (elementPtr: UnsafePointer<CGPathElement>) in
                let element = elementPtr.pointee
                var pointsPtr = element.points
                let pt = simd_double2(pointsPtr.pointee.x, pointsPtr.pointee.y)

                switch element.type {
                case .moveToPoint:
                    myPath.append(pt) //ADD
                case .addLineToPoint:
                    let myA = myPath.last!
                    let length = simd_length(pt - myA)
                    var data: [simd_double2] = []
                    if length > distanceLimit {
                        let sections = Int(max(ceil(length / distanceLimit), 2))
                        let inc = 1.0 / Double(sections - 1)
                        var t = simd_double2(0.0, 0.0)
                        for _ in 0..<sections {
                            data.append(simd_mix(myA, pt, t))
                            t += inc
                            t = min(max(t, 0.0), 1.0)
                        }
                    } else {
                        data.append(myA)
                        data.append(pt)
                    }
                    data.removeFirst()
                    myPath += data
                case .addQuadCurveToPoint:
                    let myB = pt
                    pointsPtr += 1
                    let myA = myPath.last!
                    let myC = simd_double2(pointsPtr.pointee.x, pointsPtr.pointee.y)
                    let aVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.0))
                    let bVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.5))
                    let cVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 1.0))
                    var data: [simd_double2] = []
                    data.append(myA)
                    MainFunctions.adaptiveQuadraticBezierCurve2(a: myA, b: myB, c: myC, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
                    data.append(myC)
                    data.removeFirst()
                    myPath += data
                case .addCurveToPoint:
                    let myA = myPath.last!
                    let myB = pt
                    pointsPtr += 1
                    let myC = simd_double2(pointsPtr.pointee.x, pointsPtr.pointee.y)
                    pointsPtr += 1
                    let myD = simd_double2(pointsPtr.pointee.x, pointsPtr.pointee.y)

                    let aVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.0))
                    let bVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.5))
                    let cVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 1.0))
                    var data: [simd_double2] = []
                    data.append(myA)
                    MainFunctions.adaptiveQubicBezierCurve2(a: myA, b: myB, c: myC, d: myD, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data, maxDepth: maxDepth)
                    data.append(myD)
                    data.removeFirst()
                    myPath += data
                case .closeSubpath:
                    if myPath.first! == myPath.last! {
                        myPath.removeLast()
                    }
                    let myA = myPath.last!
                    let length = simd_length(pt - myA)
                    var data: [simd_double2] = []
                    if length > distanceLimit {
                        let sections = Int(max(ceil(length / distanceLimit), 2))
                        let inc = 1.0 / Double(sections - 1)
                        var t = simd_double2(0.0, 0.0)
                        for _ in 0..<sections {
                            data.append(simd_mix(myA, pt, t))
                            t += inc
                            t = min(max(t, 0.0), 1.0)
                        }
                    } else {
                        data.append(myA)
                        data.append(pt)
                    }
                    data.removeLast()
                    data.removeFirst()
                    myPath += data
                    myGlyphPaths.append(myPath)
                    myPath.removeAll()
                default:
                    break
                }
            }
            return myGlyphPaths
        }
        public typealias Hole = [simd_double2]
        public class TriangulateHelperData {
            public var path: [simd_double2] = []
            public var holes: [Hole] = []
        }

        /// Creates a new triangulator with the specified precision
        /// - Parameter precision: The minimum required precision. It's a minimum linear distance after which points will be recognized as the same.
        /// For example with precision = 0.1 points (1; 1), (1; 0.05) will be equal
        /// Keep in mind that your maximum point length depend on this value by the formula: precision * 10^9
        /// For example:
        /// with precision = 0.1 your maximum allowed point is (100kk, 100kk)
        /// with precision = 0.0001 your maximum allowed point is (100k, 100k)
        /// with precision = 0.0000001 your maximum allowed point is (100, 100)
        /// If your broke this rule, the calculation will be undefinied
        public static func triangulate(_ calculatedPaths: [[[simd_double2]]], isClockwiseFont: Bool, precision: Double) -> [[[simd_double2]]] {
            let TRIANGULATOR = Triangulator(precision: precision)
            var triangulatedPaths: [[[simd_double2]]] = []
            for letter in calculatedPaths {
                triangulatedPaths.append([])
                var tempHelperDatas: [TriangulateHelperData] = []
                for portion in letter {
                    if tempHelperDatas.isEmpty {
                        tempHelperDatas.append(TriangulateHelperData())
                        if isClockwiseFont {
                            tempHelperDatas[tempHelperDatas.count-1].path = portion.map{$0}.reversed()
                        } else {
                            tempHelperDatas[tempHelperDatas.count-1].path = portion.map{$0}
                        }
                    } else {
                        if isClockwiseFont {
                            tempHelperDatas[tempHelperDatas.count-1].holes.append(portion.map{$0}.reversed())
                        } else {
                            tempHelperDatas[tempHelperDatas.count-1].holes.append(portion.map{$0})
                        }
                    }
                }
                for helperData in tempHelperDatas {
                    let allPath: [simd_double2] = helperData.path + helperData.holes.reduce([], +)
                    var slices: [ArraySlice<simd_double2>] = []
                    var currentIndex = helperData.path.count
                    for hole in helperData.holes {
                        slices.append(allPath[currentIndex..<currentIndex+hole.count])
                        currentIndex += hole.count
                    }
                    if let triangles = try? TRIANGULATOR.triangulateDelaunay(
                        points: allPath,
                        hull: allPath[0..<helperData.path.count],
                        holes: slices,
                        extraPoints: nil) {
                        triangulatedPaths[triangulatedPaths.count-1].append( triangles.map{
                            simd_double2(allPath[$0].x, allPath[$0].y)
                        })
                    }
                }
            }
            return triangulatedPaths
        }

        /// Creates a new triangulator with the specified precision
        /// - Parameter precision: The minimum required precision. It's a minimum linear distance after which points will be recognized as the same.
        /// For example with precision = 0.1 points (1; 1), (1; 0.05) will be equal
        /// Keep in mind that your maximum point length depend on this value by the formula: precision * 10^9
        /// For example:
        /// with precision = 0.1 your maximum allowed point is (100kk, 100kk)
        /// with precision = 0.0001 your maximum allowed point is (100k, 100k)
        /// with precision = 0.0000001 your maximum allowed point is (100, 100)
        /// If your broke this rule, the calculation will be undefinied
        public static func triangulate(_ calculatedPaths: [[[simd_double2]]], precision: Double) -> [[[simd_double2]]] {
            var triangulatedPaths = triangulate(calculatedPaths, isClockwiseFont: true, precision: precision)
            if triangulatedPaths.reduce(0, { r, elem in r + elem.count }) == 0 {
                triangulatedPaths = triangulate(calculatedPaths, isClockwiseFont: false, precision: precision)
            }
            return triangulatedPaths
        }

        /// Creates a new triangulator with the specified precision
        /// - Parameter precision: The minimum required precision. It's a minimum linear distance after which points will be recognized as the same.
        /// For example with precision = 0.1 points (1; 1), (1; 0.05) will be equal
        /// Keep in mind that your maximum point length depend on this value by the formula: precision * 10^9
        /// For example:
        /// with precision = 0.1 your maximum allowed point is (100kk, 100kk)
        /// with precision = 0.0001 your maximum allowed point is (100k, 100k)
        /// with precision = 0.0000001 your maximum allowed point is (100, 100)
        /// If your broke this rule, the calculation will be undefinied
        public static func triangulateWithoutLetterOffset(_ calculatedPaths: [[[simd_double2]]], precision: Double) -> (paths: [[[simd_double2]]], letterOffsets: [simd_double3]) {
            var result = triangulateWithoutLetterOffset(calculatedPaths, isClockwiseFont: true, precision: precision)
            if result.paths.reduce(0, { r, elem in r + elem.count }) == 0 {
                result = triangulateWithoutLetterOffset(calculatedPaths, isClockwiseFont: false, precision: precision)
            }
            return result
        }

        /// Creates a new triangulator with the specified precision
        /// - Parameter precision: The minimum required precision. It's a minimum linear distance after which points will be recognized as the same.
        /// For example with precision = 0.1 points (1; 1), (1; 0.05) will be equal
        /// Keep in mind that your maximum point length depend on this value by the formula: precision * 10^9
        /// For example:
        /// with precision = 0.1 your maximum allowed point is (100kk, 100kk)
        /// with precision = 0.0001 your maximum allowed point is (100k, 100k)
        /// with precision = 0.0000001 your maximum allowed point is (100, 100)
        /// If your broke this rule, the calculation will be undefinied
        public static func triangulateWithoutLetterOffset(
            _ calculatedPaths: [[[simd_double2]]],
            isClockwiseFont: Bool,
            precision: Double
        ) -> (
            paths: [[[simd_double2]]],
            letterOffsets: [simd_double3]
        ) {
            let TRIANGULATOR = Triangulator(precision: precision)
            var triangulatedPaths: [[[simd_double2]]] = []
            var letterOffsets: [simd_double3] = []
            for letter in calculatedPaths {
                triangulatedPaths.append([])
                var tempHelperDatas: [TriangulateHelperData] = []
                for portion in letter {
                    if tempHelperDatas.isEmpty {
                        tempHelperDatas.append(TriangulateHelperData())
                        if isClockwiseFont {
                            tempHelperDatas[tempHelperDatas.count-1].path = portion.reversed()
                        } else {
                            tempHelperDatas[tempHelperDatas.count-1].path = portion
                        }
                    } else {
                        if isClockwiseFont {
                            tempHelperDatas[tempHelperDatas.count-1].holes.append(portion.reversed())
                        } else {
                            tempHelperDatas[tempHelperDatas.count-1].holes.append(portion)
                        }
                    }
                }
                for helperData in tempHelperDatas {
                    let allPath: [simd_double2] = helperData.path + helperData.holes.reduce([], +)
                    var slices: [ArraySlice<simd_double2>] = []
                    var currentIndex = helperData.path.count
                    for hole in helperData.holes {
                        slices.append(allPath[currentIndex..<currentIndex+hole.count])
                        currentIndex += hole.count
                    }
                    if let triangles = try? TRIANGULATOR.triangulateDelaunay(
                        points: allPath,
                        hull: allPath[0..<helperData.path.count],
                        holes: slices,
                        extraPoints: nil) {
                        triangulatedPaths[triangulatedPaths.count-1].append( triangles.map{
                            simd_double2(allPath[$0].x, allPath[$0].y)
                        })
                        letterOffsets.append(simd_double3.zero)
                    }
                }
            }
            return (triangulatedPaths, letterOffsets)
        }
    }

    /// Creates a new triangulator with the specified precision
    /// - Parameter precision: The minimum required precision. It's a minimum linear distance after which points will be recognized as the same.
    /// For example with precision = 0.1 points (1; 1), (1; 0.05) will be equal
    /// Keep in mind that your maximum point length depend on this value by the formula: precision * 10^9
    /// For example:
    /// with precision = 0.1 your maximum allowed point is (100kk, 100kk)
    /// with precision = 0.0001 your maximum allowed point is (100k, 100k)
    /// with precision = 0.0000001 your maximum allowed point is (100, 100)
    /// If your broke this rule, the calculation will be undefinied
    public static func triangulate(_ pathsWithHole: [[simd_double2]], precision: Double) -> [simd_double2] {
        let result = MainFunctions.triangulate([pathsWithHole], precision: precision)
        return result.reduce([], +).reduce([], +)
    }
}
