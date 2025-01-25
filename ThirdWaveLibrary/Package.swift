// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThirdWaveLibrary",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ThirdWaveLibrary",
            targets: ["ThirdWaveLibrary"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-se0270-range-set", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ThirdWaveLibrary",
            dependencies: [
                .product(name: "SE0270_RangeSet", package: "swift-se0270-range-set")
            ]
        ),
        .executableTarget(
            name: "third-wave-tool",
            dependencies: [
                "ThirdWaveLibrary",
                .product(name: "ArgumentParser", package: "swift-argument-parser")                
            ],
            path: "Sources/ThirdWaveTool"
        ),
    ]
)
