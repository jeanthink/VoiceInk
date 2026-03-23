import Foundation
import ArgumentParser

// Note: file is named main.swift, so we call .main() at the bottom instead of using @main
struct VoiceInkServiceCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "VoiceInkService",
        abstract: "HTTP bridge service exposing VoiceInkCore to non-Swift shells",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "Port to listen on")
    var port: Int = 7523

    @Option(name: .long, help: "Host address to bind to")
    var host: String = "127.0.0.1"

    @Flag(name: .long, help: "Use stub bridge (for testing without VoiceInkCore)")
    var stub: Bool = false

    mutating func run() throws {
        print("🎙 VoiceInkService starting on \(host):\(port)")

        let bridge: CoreBridgeProtocol = stub
            ? StubCoreBridge()
            : VoiceInkCoreBridge()

        let server = HTTPServer(host: host, port: port, bridge: bridge)

        signal(SIGINT) { _ in
            print("\n🛑 VoiceInkService shutting down...")
            Darwin.exit(0)
        }
        signal(SIGTERM) { _ in Darwin.exit(0) }

        try server.start()

        RunLoop.main.run()
    }
}

VoiceInkServiceCommand.main()
