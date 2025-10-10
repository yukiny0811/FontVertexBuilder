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

public extension GlyphUtil {
    enum HelperFunctions {
        static func cubicBezierVelocity2(_ a: simd_double2, _ b: simd_double2, _ c: simd_double2, _ d: simd_double2, _ t: Double) -> simd_double2 {
            let oneMinusT = 1.0 - t
            let oneMinusT2 = oneMinusT * oneMinusT
            let temp1 = 3.0 * oneMinusT2 * (b - a)
            let temp2 = 6.0 * oneMinusT * t * (c - b)
            let temp3 = 3.0 * t * t * (d - c)
            return temp1 + temp2 + temp3
        }
        static func quadraticBezierVelocity2(_ a: simd_double2, _ b: simd_double2, _ c: simd_double2, _ t: Double) -> simd_double2 {
            let oneMinusT: Double = 1.0 - t
            return 2 * oneMinusT * (b-a) + 2 * t * (c-b)
        }
        
        // maybe not working? unused.
        static func isVertexStructureClockwise(data: [simd_double2]) -> Bool {
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
}
