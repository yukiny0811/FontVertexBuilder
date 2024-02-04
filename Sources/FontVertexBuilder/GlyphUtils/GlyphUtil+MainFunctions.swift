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

import simd
import CoreGraphics
import CoreText
import iGeometry
import iShapeTriangulation
import SimpleSimdSwift

public extension GlyphUtil {
    enum MainFunctions {
        private static let DEPTH: Int = 8
        static func adaptiveQubicBezierCurve2(
            a: f2,
            b: f2,
            c: f2,
            d: f2,
            aVel: f2,
            bVel: f2,
            cVel: f2,
            angleLimit: Float,
            depth: Int,
            line: inout [f2]
        ) {
            if Self.DEPTH > 8 { return }
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
                Self.adaptiveQubicBezierCurve2(a: a, b: ab, c: abc, d: abcd, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line)
                line.append(abcd)
                let eVel = simd_normalize(HelperFunctions.cubicBezierVelocity2(abcd, bcd, cd, d, 0.5))
                Self.adaptiveQubicBezierCurve2(a: abcd, b: bcd, c: cd, d: d, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line)
            }
        }
        static func adaptiveQuadraticBezierCurve2(
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
        static func getGlyphLines(_ glyphPath: CGPath, _ angleLimit: Float, _ distanceLimit: Float) -> [GlyphLine] {
            var myPath = GlyphLine()
            var myGlyphPaths = [GlyphLine]()
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
                    let aVel = simd_normalize(GlyphUtil.HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.0))
                    let bVel = simd_normalize(GlyphUtil.HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.5))
                    let cVel = simd_normalize(GlyphUtil.HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 1.0))
                    var data: [simd_float2] = []
                    data.append(myA)
                    GlyphUtil.MainFunctions.adaptiveQuadraticBezierCurve2(a: myA, b: myB, c: myC, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
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
                    
                    let aVel = simd_normalize(GlyphUtil.HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.0))
                    let bVel = simd_normalize(GlyphUtil.HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.5))
                    let cVel = simd_normalize(GlyphUtil.HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 1.0))
                    var data: [simd_float2] = []
                    data.append(myA)
                    GlyphUtil.MainFunctions.adaptiveQubicBezierCurve2(a: myA, b: myB, c: myC, d: myD, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
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
        typealias Hole = [f2]
        class TriangulateHelperData {
            public var path: [f2] = []
            public var holes: [Hole] = []
        }
        
        private static let TRIANGULATOR = Triangulator(precision: 0.0001)
        
        public static func triangulate(_ calculatedPaths: [LetterPath], isClockwiseFont: Bool) -> [TriangulatedLetterPath] {
            var triangulatedPaths: [TriangulatedLetterPath] = []
            for letter in calculatedPaths {
                triangulatedPaths.append(TriangulatedLetterPath(glyphLines: [], offset: f3(letter.offset.x, letter.offset.y, 0)))
                var tempHelperDatas: [TriangulateHelperData] = []
                for portion in letter.glyphs {
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
                        triangulatedPaths[triangulatedPaths.count-1].glyphLines.append( triangles.map{
                            f3(allPath[$0].x, allPath[$0].y, 0) + f3(letter.offset.x, letter.offset.y, 0)
                        })
                    }
                }
            }
            return triangulatedPaths
        }
        
        public static func triangulate(_ calculatedPaths: [LetterPath]) -> [TriangulatedLetterPath] {
            var triangulatedPaths = triangulate(calculatedPaths, isClockwiseFont: true)
            if triangulatedPaths.reduce(0, { r, elem in r + elem.glyphLines.count }) == 0 {
                triangulatedPaths = triangulate(calculatedPaths, isClockwiseFont: false)
            }
            return triangulatedPaths
        }
        
        public static func triangulateWithoutLetterOffset(_ calculatedPaths: [LetterPath], isClockwiseFont: Bool) -> (paths: [TriangulatedLetterPath], letterOffsets: [f3]) {
            var triangulatedPaths: [TriangulatedLetterPath] = []
            var letterOffsets: [f3] = []
            for letter in calculatedPaths {
                triangulatedPaths.append(TriangulatedLetterPath(glyphLines: [], offset: f3(letter.offset.x, letter.offset.y, 0)))
                var tempHelperDatas: [TriangulateHelperData] = []
                for portion in letter.glyphs {
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
                        triangulatedPaths[triangulatedPaths.count-1].glyphLines.append( triangles.map{
                            f3(allPath[$0].x, allPath[$0].y, 0)
                        })
                        letterOffsets.append(f3(letter.offset.x, letter.offset.y, 0))
                    }
                }
            }
            return (triangulatedPaths, letterOffsets)
        }
    }
}
