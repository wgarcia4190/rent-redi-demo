// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RentRediUI",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "RentRediUI",
            targets: ["RentRediUI"]
        ),
    ],
    targets: [
        .target(
            name: "RentRediUI",
            path: "Sources/RentRediUI"
        ),
    ]
)
