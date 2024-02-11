// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scenery",
    products: [
        .library(
            name: "Scenery",
            targets: ["Scenery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gavineadie/SatelliteKit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Scenery",
            dependencies: [ .product(name: "SatelliteKit", package: "SatelliteKit") ]),
            .testTarget(
                name: "SceneryTests",
                dependencies: ["Scenery"]),
    ]
)
