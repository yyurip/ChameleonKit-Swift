// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChameleonKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "ChameleonColorizer",
            targets: ["ChameleonColorizer"]
        ),
        .library(
            name: "ChameleonConverter",
            targets: ["ChameleonConverter"]
        )
    ],
    dependencies: [
        .package(name: "Zip", url: "https://github.com/LottieFiles/Zip.git", from: "2.1.2")
    ],
    targets: [
        .target(
            name: "ChameleonColorizer",
            dependencies: ["ChameleonConverter"],
            path: "Sources/ChameleonColorizer"
        ),
        .target(
            name: "ChameleonConverter",
            dependencies: ["Zip"],
            path: "Sources/ChameleonConverter"
        ),
        .testTarget(
            name: "ChameleonColorizerTests",
            dependencies: ["ChameleonColorizer"]
        )
    ]
)
