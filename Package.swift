// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigurableKit",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "ConfigurableKit", targets: ["ConfigurableKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
        .package(url: "https://github.com/Lakr233/ChidoriMenu", from: "3.0.0"),
    ],
    targets: [
        .target(name: "ConfigurableKit", dependencies: [
            .product(name: "OrderedCollections", package: "swift-collections"),
            "ChidoriMenu",
        ]),
    ]
)
