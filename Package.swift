// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Square",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Square",
            targets: [
                "Square"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/auremsinistram/Extensions.git",
            from: .init(0, 1, 0)
        )
    ],
    targets: [
        .target(
            name: "Square",
            dependencies: [
                .product(
                    name: "Extensions"
                )
            ]
        )
    ]
)
