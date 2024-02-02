//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/28.
//

import Foundation
import SimpleSimdSwift

public typealias GlyphLine = [f2]
public typealias GlyphLineF3 = [f3]

public struct LetterPath {
    public var glyphs: [GlyphLine]
    public var offset: f2
}

public struct TriangulatedLetterPath {
    public var glyphLines: [GlyphLineF3]
    public var offset: f3
}
