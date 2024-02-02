// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FontVertexBuilder",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "FontVertexBuilder",
            targets: [
                "FontVertexBuilder"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/yukiny0811/SwiftyCoreText", from: "1.0.0"),
        .package(url: "https://github.com/yukiny0811/SimpleSimdSwift", from: "1.0.1"),
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
                "FontVertexBuilder"
            ]
        ),
    ]
)
