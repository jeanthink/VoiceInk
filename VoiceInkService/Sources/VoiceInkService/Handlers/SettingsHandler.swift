import Foundation

public struct SettingsHandler {
    static func getSettings(bridge: CoreBridgeProtocol) async -> SettingsResponse {
        await bridge.getSettings()
    }

    static func updateSettings(_ partial: [String: Any], bridge: CoreBridgeProtocol) async throws {
        try await bridge.updateSettings(partial)
    }
}
