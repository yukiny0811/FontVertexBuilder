// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FontVertexBuilder",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "FontVertexBuilder",
            targets: [
                "FontVertexBuilder",
                "SVGVertexBuilder"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/yukiny0811/SwiftyCoreText", exact: "1.0.0"),
        .package(url: "https://github.com/yukiny0811/SimpleSimdSwift", exact: "1.0.1"),
        .package(url: "https://github.com/yukiny0811/SVGPath", exact: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FontVertexBuilder",
            dependencies: [
                "iShapeTriangulation",
                "SwiftyCoreText",
                "SimpleSimdSwift"
            ]
        ),
        .target(
            name: "SVGVertexBuilder",
            dependencies: [
                "iShapeTriangulation",
                "SimpleSimdSwift",
                "SVGPath"
            ]
        ),
        .target(
            name: "iGeometry",
            dependencies: [
                "SimpleSimdSwift"
            ]
        ),
        .target(
            name: "iShapeTriangulation",
            dependencies: [
                "iGeometry",
                "SimpleSimdSwift"
            ]
        ),
        .testTarget(
            name: "FontVertexBuilderTests",
            dependencies: [
                "FontVertexBuilder",
                "SVGVertexBuilder"
            ]
        ),
    ]
)
