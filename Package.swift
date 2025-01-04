// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigurableKit",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "ConfigurableKit", targets: ["ConfigurableKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
    ],
    targets: [
        .target(name: "ConfigurableKit", dependencies: [
            "ConfigurableKitAnyCodable",
            .product(name: "OrderedCollections", package: "swift-collections"),
        ]),
        .target(name: "ConfigurableKitAnyCodable"),
    ]
)
