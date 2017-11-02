// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "capture",
    dependencies: [
        .package(url: "../../../", from: "0.5.5"),
    ],
    targets: [
        .target(
            name: "capture",
            dependencies: ["Buffie", "captureCore"]),
        .target(
            name: "captureCore",
            dependencies: ["Buffie"]),
        .testTarget(name: "captureTests", dependencies: ["captureCore"]),
    ]
)
