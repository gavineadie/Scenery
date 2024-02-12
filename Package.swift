// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Scenery",
    platforms: [
        .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7) // , .visionOS(.v1)
    ],
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
