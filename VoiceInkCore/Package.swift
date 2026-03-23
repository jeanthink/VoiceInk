// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VoiceInkCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "VoiceInkCore",
            targets: ["VoiceInkCore"])
    ],
    targets: [
        .target(
            name: "VoiceInkCore",
            dependencies: []),
        .testTarget(
            name: "VoiceInkCoreTests",
            dependencies: ["VoiceInkCore"])
    ]
)
