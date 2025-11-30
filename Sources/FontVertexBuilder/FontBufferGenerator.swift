//
//  File.swift
//  FontVertexBuilder
//
//  Created by YukiSub on 2025/11/30.
//

import MetalKit

public enum FontBufferGenerator {
    
    public static func generateBuffer(
        text: String,
        fontName: String = "Avenir-BlackOblique",
        fontSize: Double = 10.0,
        bounds: CGSize = CGSize(width: 500, height: 300),
        pivot: simd_double2 = .zero,
        textAlignment: CTTextAlignment = .center,
        verticalAlignment: PathText.VerticalAlignment = .center,
        kern: Double = 0.0,
        lineSpacing: Double = 0.0,
        maxDepth: Int = 8,
        device: MTLDevice
    ) -> (buffer: MTLBuffer, verticeCount: Int)? {
        let pathText = PathText(
            text: text,
            fontName: fontName,
            fontSize: fontSize,
            bounds: bounds,
            pivot: pivot,
            textAlignment: textAlignment,
            verticalAlignment: verticalAlignment,
            kern: kern,
            lineSpacing: lineSpacing,
            maxDepth: maxDepth
        )
        let triangulatedPaths = GlyphUtil.MainFunctions.triangulate(pathText.calculatedPaths)
        
        var finalVertices: [simd_double3] = []
        for letter in triangulatedPaths {
            for portion in letter.glyphLines {
                finalVertices += portion
            }
        }
        if finalVertices.count == 0 {
            return nil
        }
        let buf: MTLBuffer = device.makeBuffer(bytes: finalVertices.map { simd_float3($0) }, length: finalVertices.count * MemoryLayout<simd_float3>.stride)!
        return (buf, finalVertices.count)
    }
}
