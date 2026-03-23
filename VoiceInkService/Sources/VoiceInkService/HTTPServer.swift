import Foundation

/// Minimal HTTP server scaffold.
/// For production, replace with swift-nio or Vapor for proper HTTP transport.
public final class HTTPServer {
    private let host: String
    private let port: Int
    private let bridge: CoreBridgeProtocol
    private let router: Router

    public init(host: String, port: Int, bridge: CoreBridgeProtocol) {
        self.host = host
        self.port = port
        self.bridge = bridge
        self.router = Router(bridge: bridge)
    }

    public func start() throws {
        print("🌐 VoiceInkService HTTP server starting on \(host):\(port)")
        print("   Endpoints:")
        print("   GET  /health")
        print("   GET  /models")
        print("   POST /transcribe")
        print("   POST /enhance")
        print("   GET  /prompts")
        print("   POST /prompts")
        print("   DELETE /prompts/:id")
        print("   GET  /settings")
        print("   PATCH /settings")
        print("")
        print("⚠️  HTTP server implementation is stubbed — use swift-nio for production")
        print("   To add swift-nio: uncomment dependency in Package.swift")
        print("")

        Task {
            await runHealthCheck()
        }
    }

    private func runHealthCheck() async {
        let health = await bridge.health()
        print("✅ Bridge health check: \(health.status)")

        let models = await bridge.listModels()
        print("✅ Models available: \(models.count)")

        let prompts = await bridge.listPrompts()
        print("✅ Prompts available: \(prompts.count)")
    }
}
