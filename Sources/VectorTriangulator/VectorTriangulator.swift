//
//  File.swift
//
//
//  Created by Yuki Kuwashima on 2023/06/28.
//
//Original Objective-c++ Code from https://github.com/Hi-Rez/Satin (Modified and translated to Swift by Yuki Kuwashima)
//MIT License
//
//Copyright (c) 2023 Hi-Rez
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Foundation
import SimpleSimdSwift
import simd
import CoreGraphics
import CoreText
import iGeometry
import iShapeTriangulation

public enum VectorTriangulator {
    public enum HelperFunctions {
        public static func cubicBezierVelocity2(_ a: f2, _ b: f2, _ c: f2, _ d: f2, _ t: Float) -> f2 {
            let oneMinusT = 1.0 - t
            let oneMinusT2 = oneMinusT * oneMinusT
            let temp1 = 3.0 * oneMinusT2 * (b - a)
            let temp2 = 6.0 * oneMinusT * t * (c - b)
            let temp3 = 3.0 * t * t * (d - c)
            return temp1 + temp2 + temp3
        }
        public static func quadraticBezierVelocity2(_ a: f2, _ b: f2, _ c: f2, _ t: Float) -> f2 {
            let oneMinusT: Float = 1.0 - t
            return 2 * oneMinusT * (b-a) + 2 * t * (c-b)
        }

        // maybe not working? unused.
        public static func isVertexStructureClockwise(data: [f2]) -> Bool {
            var area: Float = 0
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
            a: f2,
            b: f2,
            c: f2,
            d: f2,
            aVel: f2,
            bVel: f2,
            cVel: f2,
            angleLimit: Float,
            depth: Int,
            line: inout [f2],
            maxDepth: Int
        ) {
            if depth > maxDepth { return }
            let startMiddleAngle: Float = acos(simd_dot(aVel, bVel))
            let middleEndAngle: Float = acos(simd_dot(bVel, cVel))
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
            a: simd_float2,
            b: simd_float2,
            c: simd_float2,
            aVel: simd_float2,
            bVel: simd_float2,
            cVel: simd_float2,
            angleLimit: Float,
            depth: Int,
            line: inout [simd_float2]
        ) {
            if depth > 8 { return }
            let startMiddleAngle: Float = acos(simd_dot(aVel, bVel))
            let middleEndAngle: Float = acos(simd_dot(bVel, cVel))
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
        public static func getGlyphLines(_ glyphPath: CGPath, _ angleLimit: Float, _ distanceLimit: Float, maxDepth: Int) -> [[f2]] {
            var myPath = [f2]()
            var myGlyphPaths = [[f2]]()
            glyphPath.applyWithBlock { (elementPtr: UnsafePointer<CGPathElement>) in
                let element = elementPtr.pointee
                var pointsPtr = element.points
                let pt = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))

                switch element.type {
                case .moveToPoint:
                    myPath.append(pt) //ADD
                case .addLineToPoint:
                    let myA = myPath.last!
                    let length = simd_length(pt - myA)
                    var data: [simd_float2] = []
                    if length > distanceLimit {
                        let sections = Int(max(ceil(length / distanceLimit), 2))
                        let inc = 1.0 / Float(sections - 1)
                        var t = simd_float2(0.0, 0.0)
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
                    let myC = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                    let aVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.0))
                    let bVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.5))
                    let cVel = simd_normalize(HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 1.0))
                    var data: [simd_float2] = []
                    data.append(myA)
                    MainFunctions.adaptiveQuadraticBezierCurve2(a: myA, b: myB, c: myC, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
                    data.append(myC)
                    data.removeFirst()
                    myPath += data
                case .addCurveToPoint:
                    let myA = myPath.last!
                    let myB = pt
                    pointsPtr += 1
                    let myC = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                    pointsPtr += 1
                    let myD = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))

                    let aVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.0))
                    let bVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.5))
                    let cVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 1.0))
                    var data: [simd_float2] = []
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
                    var data: [simd_float2] = []
                    if length > distanceLimit {
                        let sections = Int(max(ceil(length / distanceLimit), 2))
                        let inc = 1.0 / Float(sections - 1)
                        var t = simd_float2(0.0, 0.0)
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
        public typealias Hole = [f2]
        public class TriangulateHelperData {
            public var path: [f2] = []
            public var holes: [Hole] = []
        }

        public static let TRIANGULATOR = Triangulator(precision: 0.0001)

        public static func triangulate(_ calculatedPaths: [[[f2]]], isClockwiseFont: Bool) -> [[[f2]]] {
            var triangulatedPaths: [[[f2]]] = []
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
                    let allPath: [f2] = helperData.path + helperData.holes.reduce([], +)
                    var slices: [ArraySlice<f2>] = []
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
                            f2(allPath[$0].x, allPath[$0].y)
                        })
                    }
                }
            }
            return triangulatedPaths
        }

        public static func triangulate(_ calculatedPaths: [[[f2]]]) -> [[[f2]]] {
            var triangulatedPaths = triangulate(calculatedPaths, isClockwiseFont: true)
            if triangulatedPaths.reduce(0, { r, elem in r + elem.count }) == 0 {
                triangulatedPaths = triangulate(calculatedPaths, isClockwiseFont: false)
            }
            return triangulatedPaths
        }

        public static func triangulateWithoutLetterOffset(_ calculatedPaths: [[[f2]]]) -> (paths: [[[f2]]], letterOffsets: [f3]) {
            var result = triangulateWithoutLetterOffset(calculatedPaths, isClockwiseFont: true)
            if result.paths.reduce(0, { r, elem in r + elem.count }) == 0 {
                result = triangulateWithoutLetterOffset(calculatedPaths, isClockwiseFont: false)
            }
            return result
        }

        public static func triangulateWithoutLetterOffset(_ calculatedPaths: [[[f2]]], isClockwiseFont: Bool) -> (paths: [[[f2]]], letterOffsets: [f3]) {
            var triangulatedPaths: [[[f2]]] = []
            var letterOffsets: [f3] = []
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
                    let allPath: [f2] = helperData.path + helperData.holes.reduce([], +)
                    var slices: [ArraySlice<f2>] = []
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
                            f2(allPath[$0].x, allPath[$0].y)
                        })
                        letterOffsets.append(f3.zero)
                    }
                }
            }
            return (triangulatedPaths, letterOffsets)
        }
    }

    public static func triangulate(_ pathsWithHole: [[f2]]) -> [f2] {
        let result = MainFunctions.triangulate([pathsWithHole])
        return result.reduce([], +).reduce([], +)
    }
}

