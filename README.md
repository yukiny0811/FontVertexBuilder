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

## Acknowledgements

### Font -> Path algorithms
Original algorithms are from https://github.com/Hi-Rez/Satin.
Translated from obj-c code to Swift, and made some modifications.
License text is written directly in the source code.

### Vector operations on Integer field
Original code is obtained from https://github.com/iShape-Swift/iGeometry.
Some modifications are made for convenience.
See [LICENSE](https://github.com/yukiny0811/FontVertexBuilder/blob/main/Sources/iGeometry/iGeometry_LICENSE)

### Triangulation
Original code is obtained from https://github.com/iShape-Swift/iShapeTriangulation.
Some modifications are made for convenience.
See [LICENSE](https://github.com/yukiny0811/FontVertexBuilder/blob/main/Sources/iShapeTriangulation/iShapeTriangulation_LICENSE)
