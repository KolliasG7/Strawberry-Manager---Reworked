// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StrawberryManager",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "StrawberryManager",
            targets: ["StrawberryManager"]
        )
    ],
    dependencies: [
        // No external dependencies needed - using system frameworks
    ],
    targets: [
        .target(
            name: "StrawberryManager",
            path: ".",
            exclude: [
                "README.md",
                "Package.swift",
                "Tests"
            ],
            sources: [
                "Models",
                "ViewModels",
                "Views",
                "Services",
                "Utilities"
            ]
        ),
        .testTarget(
            name: "StrawberryManagerTests",
            dependencies: ["StrawberryManager"],
            path: "Tests"
        )
    ]
)
