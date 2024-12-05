// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LottieColorize",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "LottieColorize",
            targets: ["LottieColorize"]),
    ],
    dependencies: [
        .package(name: "Zip", url: "https://github.com/LottieFiles/Zip.git", from: "2.1.2")
    ],
    targets: [
        .target(
            name: "LottieColorize",
            dependencies: ["Zip"],
            path: "Sources"
        ),
        .testTarget(
            name: "LottieColorizeTests",
            dependencies: ["LottieColorize"]
        )
    ]
)
