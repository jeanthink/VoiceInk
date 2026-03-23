import Vapor
import Foundation

@main
struct VoiceInkServiceApp {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = Application(env)
        defer { app.shutdown() }
        
        try configure(app)
        try app.run()
    }
}

func configure(_ app: Application) throws {
    let port = Environment.get("PORT").flatMap(Int.init) ?? 8787
    app.http.server.configuration.hostname = "127.0.0.1"
    app.http.server.configuration.port = port
    
    let coreBridge = try CoreBridge()
    app.storage[CoreBridgeKey.self] = coreBridge
    
    try routes(app)
    
    app.logger.info("VoiceInkService starting on http://127.0.0.1:\(port)")
}

func routes(_ app: Application) throws {
    try app.register(collection: HealthController())
    try app.register(collection: TranscriptionController())
    try app.register(collection: EnhancementController())
}

struct CoreBridgeKey: StorageKey {
    typealias Value = CoreBridge
}

extension Application {
    var coreBridge: CoreBridge {
        get {
            guard let bridge = storage[CoreBridgeKey.self] else {
                fatalError("CoreBridge not configured")
            }
            return bridge
        }
        set {
            storage[CoreBridgeKey.self] = newValue
        }
    }
}

extension Request {
    var coreBridge: CoreBridge {
        application.coreBridge
    }
}
