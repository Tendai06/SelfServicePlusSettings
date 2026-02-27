// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SelfServicePlusSettings",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SelfServicePlusSettings",
            targets: ["SelfServicePlusSettings"]),
        .executable(
            name: "VerifySelfServicePlusSettings",
            targets: ["SelfServicePlusSettingsTests"]),
    ],
    targets: [
        .target(
            name: "SelfServicePlusSettings",
            dependencies: []),
        .executableTarget(
            name: "SelfServicePlusSettingsTests",
            dependencies: ["SelfServicePlusSettings"],
            path: "Tests/SelfServicePlusSettingsTests"),
    ]
)
