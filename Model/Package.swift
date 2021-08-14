// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Model",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Model",
            targets: ["Model"]
        ),
    ],
    dependencies: [
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "Model",
            dependencies: [
                .product(name: "GRDB", package: "GRDB")
            ])
    ]
)
