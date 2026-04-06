// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigurableKit",
    platforms: [
        .iOS(.v16),
        .macCatalyst(.v16),
        .macOS(.v12),
    ],
    products: [
        .library(name: "ConfigurableKit", targets: ["ConfigurableKit"]),
        .executable(name: "ConfigurableMacDemo", targets: ["ConfigurableMacDemo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.3.0"),
    ],
    targets: [
        .target(name: "ConfigurableKit", dependencies: [
            .product(name: "OrderedCollections", package: "swift-collections"),
        ]),
        .executableTarget(
            name: "ConfigurableMacDemo",
            dependencies: ["ConfigurableKit"],
            path: "Example/ConfigurableMacDemo"
        ),
    ]
)
