import Foundation

public struct EnhanceHandler {
    static func handle(request: EnhanceRequest, bridge: CoreBridgeProtocol) async throws -> EnhanceResponse {
        try await bridge.enhance(request: request)
    }
}
