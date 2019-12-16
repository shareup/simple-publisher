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
        .package(path: "~/src/github.com/shareup/forever"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SimplePublisher",
            dependencies: []),
        .testTarget(
            name: "SimplePublisherTests",
            dependencies: ["SimplePublisher", "Forever"]),
    ]
)
