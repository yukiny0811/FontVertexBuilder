//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2024/02/05.
//

import Foundation
import SimpleSimdSwift

public typealias SVGGlyphLine = [f2]

public struct SVGPathObject {
    public init(glyphs: [SVGGlyphLine], offset: f2) {
        self.glyphs = glyphs
        self.offset = offset
    }
    public var glyphs: [SVGGlyphLine]
    public var offset: f2
}

public struct TriangulatedSVGPath {
    public var glyphLines: [SVGGlyphLine]
    public var offset: f2
}
