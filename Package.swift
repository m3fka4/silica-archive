// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Silica",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Silica", targets: ["Silica"])
    ],
    targets: [
        .executableTarget(
            name: "Silica",
            path: "Silica",
            exclude: [
                "Extensions"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SilicaTests",
            dependencies: ["Silica"],
            path: "Tests/SilicaTests"
        )
    ]
)
