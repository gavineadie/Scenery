// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Scenery",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v7), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Scenery",
            targets: ["Scenery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gavineadie/DemosKit.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Scenery",
            dependencies: [ .product(name: "DemosKit", package: "DemosKit") ]),
		.testTarget(
			name: "SceneryTests",
			dependencies: ["Scenery"]),
    ]
)
