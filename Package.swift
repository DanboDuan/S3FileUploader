// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "S3FileUploader",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "S3FileUploader",
            targets: ["S3FileUploader"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .revision("492fe8dbf50c6f906444dbc227d3edb35ab0f4a7")),
    ],
    targets: [
        .executableTarget(
            name: "S3FileUploader",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
            ]
        ),
        .testTarget(
            name: "S3FileUploaderTests",
            dependencies: ["S3FileUploader"]
        ),
    ]
)
