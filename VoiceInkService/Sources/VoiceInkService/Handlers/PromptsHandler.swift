import Foundation

public struct PromptsHandler {
    static func listPrompts(bridge: CoreBridgeProtocol) async -> [PromptResponse] {
        await bridge.listPrompts()
    }

    static func createPrompt(_ request: CreatePromptRequest, bridge: CoreBridgeProtocol) async throws -> PromptResponse {
        try await bridge.createPrompt(request)
    }

    static func deletePrompt(id: String, bridge: CoreBridgeProtocol) async throws {
        try await bridge.deletePrompt(id: id)
    }
}
