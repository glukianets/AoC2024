// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AdventOfCode2024",
    platforms: [.macOS("15")],
    products: [
        .executable(
            name: "AdventOfCode2024",
            targets: ["AdventOfCode2024"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode2024",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .testTarget(
            name: "AdventOfCode2024Tests",
            dependencies: [
                "AdventOfCode2024",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
    ]
)
