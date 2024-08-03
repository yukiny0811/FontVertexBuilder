//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2024/02/05.
//

import SimpleSimdSwift
import Foundation
import iShapeTriangulation
import SVGPath
import CoreGraphics

open class SVG: NSObject, XMLParserDelegate {
    
    var cgPaths: [CGPath] = []
    var parsingFinished = false
    var maxDepth: Int

    public var triangulatedPaths: [SVGGlyphLine] = []
    
    public init? (url: URL, maxDepth: Int = 8) async {
        guard let parser = XMLParser(contentsOf: url) else {
            return nil
        }
        self.maxDepth = maxDepth
        super.init()
        parser.delegate = self
        parser.parse()
        let _ : Any? = await withCheckedContinuation { continuation in
            continuation.resume(returning: nil)
        }
    }
    
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        guard elementName == "path" else {
            return
        }
        guard let pathString = attributeDict["d"] else {
            return
        }
        guard let path = try? CGPath.from(svgPath: pathString) else {
            return
        }
        cgPaths.append(path)
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        var parsed: [SVGPathObject] = []
        for cgPath in cgPaths {
            let glyphLines = SVGUtil.MainFunctions.getGlyphLines(cgPath, maxDepth: maxDepth)
            parsed.append(.init(glyphs: glyphLines, offset: .zero))
        }
        
        var triangulated: [TriangulatedSVGPath] = []
        for p in parsed {
            for g in p.glyphs {
                let temp = SVGUtil.MainFunctions.triangulate([.init(glyphs: [g], offset: .zero)])
                triangulated += temp
            }
        }
        
        var temp: [SVGGlyphLine] = []
        for t in triangulated {
            temp += t.glyphLines
        }
        triangulatedPaths = temp
        parsingFinished = true
    }
}
