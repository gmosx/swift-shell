// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Shell",
    products: [
        .library(
            name: "Shell",
            targets: ["Shell"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Shell",
            dependencies: [
                "Utility",
            ]
        ),
        .testTarget(
            name: "ShellTests",
            dependencies: ["Shell"]
        ),
    ]
)
