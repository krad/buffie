// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Buffie",
    products: [
        .library(name: "Buffie", type: .dynamic, targets: ["Buffie"]),
    ],
    dependencies: [ ],
    targets: [
        .target(name: "Buffie", dependencies: []),
        .testTarget(name: "BuffieTests", dependencies: ["Buffie"]),
    ]
)
