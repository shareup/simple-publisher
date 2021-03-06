// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SimplePublisher",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v5),
    ],
    products: [
        .library(
            name: "SimplePublisher",
            targets: ["SimplePublisher"]),
    ],
    dependencies: [
        .package(url: "https://github.com/shareup/synchronized.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/shareup/forever.git", .upToNextMajor(from: "0.0.0")),
    ],
    targets: [
        .target(
            name: "SimplePublisher",
            dependencies: ["Synchronized"]),
        .testTarget(
            name: "SimplePublisherTests",
            dependencies: ["SimplePublisher", "Forever"]),
    ]
)
