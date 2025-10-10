//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/28.
//

import Foundation
import SimpleSimdSwift

public typealias GlyphLine = [simd_double2]
public typealias GlyphLineF3 = [simd_double3]

public struct LetterPath {
    public var glyphs: [GlyphLine]
    public var offset: simd_double2
}

public struct TriangulatedLetterPath {
    public var glyphLines: [GlyphLineF3]
    public var offset: simd_double3
}
