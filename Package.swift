// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyEMVTags",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftyEMVTags",
            targets: ["SwiftyEMVTags"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            name: "SwiftyBERTLV",
            url: "https://github.com/kaphacius/swifty-ber-tlv",
            from: .init(stringLiteral: "0.4.7")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftyEMVTags",
            dependencies: ["SwiftyBERTLV"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SwiftyEMVTagsTests",
            dependencies: ["SwiftyEMVTags"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
