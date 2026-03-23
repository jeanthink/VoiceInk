import Foundation

public struct HealthHandler {
    static func handle(bridge: CoreBridgeProtocol) async -> HealthResponse {
        await bridge.health()
    }
}
