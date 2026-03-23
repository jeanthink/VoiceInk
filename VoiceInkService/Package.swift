// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VoiceInkService",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "VoiceInkService",
            targets: ["VoiceInkService"]),
    ],
    dependencies: [
        // VoiceInkCore will be added as a local package dependency once extracted
        // .package(path: "../VoiceInkCore"),

        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "VoiceInkService",
            dependencies: [
                // .product(name: "VoiceInkCore", package: "VoiceInkCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/VoiceInkService"
        ),
    ]
)
