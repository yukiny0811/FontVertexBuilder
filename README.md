# FontVertexBuilder

Creates triangulated meshes from text font.

## Usage

Use ```PathText``` to create line path from text font, and use ```GlyphUtil``` to create triangulated meshes from line path.

```.swift
let pathText = PathText.init(
    text: "ABCDE",
    fontName: "AppleSDGothicNeo-Bold",
    fontSize: 10,
    bounds: .zero,
    pivot: .zero,
    textAlignment: .natural,
    verticalAlignment: .center,
    kern: 0,
    lineSpacing: 0,
    isClockwiseFont: true
)
let triangulatedMesh = GlyphUtil.MainFunctions.triangulate(pathText.calculatedPaths, isClockwiseFont: true)
```
