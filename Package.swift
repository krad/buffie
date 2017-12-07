// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Buffie",
    products: [
        .library(name: "Buffie", type: .dynamic, targets: ["Buffie"]),
    ],
    dependencies: [ 
      .package(url: "https://github.com/krad/boyermoore.git", from: "0.0.4"),
    ],
    targets: [
        .target(name: "Buffie", dependencies: ["BoyerMoore"]),
        .testTarget(name: "BuffieTests", dependencies: ["Buffie"]),
    ]
)
