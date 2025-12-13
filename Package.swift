// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RCKML",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "RCKML",
            targets: ["RCKML"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", .upToNextMajor(from: "4.6.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(
            name: "RCKML",
            dependencies: ["AEXML", "ZIPFoundation"]),
        .testTarget(
            name: "RCKMLTests",
            dependencies: ["RCKML", "AEXML", "ZIPFoundation"],
            resources: [.process("SampleData/GoogleSample.kml")]
        ),
    ]
)
