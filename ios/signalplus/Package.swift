// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "signalplus",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "signalplus", targets: ["signalplus"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "signalplus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
