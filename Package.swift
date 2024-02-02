// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FontVertexBuilder",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "FontVertexBuilder",
            targets: [
                "FontVertexBuilder"
            ]
        ),
    ],
    targets: [
        .target(
            name: "FontVertexBuilder"
        ),
        .testTarget(
            name: "FontVertexBuilderTests",
            dependencies: [
                "FontVertexBuilder"
            ]
        ),
    ]
)
