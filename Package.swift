// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CreatorShortVideoApp",
    platforms: [
        .iOS(.v18),
        .macOS(.v13)
    ],
    products: [
        .library(name: "CreatorShortVideoApp", targets: ["CreatorShortVideoApp"])
    ],
    targets: [
        .target(name: "CreatorShortVideoApp")
    ]
)
