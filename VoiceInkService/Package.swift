// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VoiceInkService",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../VoiceInkCore"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "VoiceInkService",
            dependencies: [
                .product(name: "VoiceInkCore", package: "VoiceInkCore"),
                .product(name: "Vapor", package: "vapor")
            ]
        )
    ]
)
