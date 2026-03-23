import Foundation

/// Abstract interface over VoiceInkCore — allows testing without the Swift Package dependency.
/// In production, VoiceInkCoreBridge implements this using the real VoiceInkCore package.
/// In testing/stub mode, StubCoreBridge provides predictable responses.
public protocol CoreBridgeProtocol: AnyObject {
    func health() async -> HealthResponse
    func listModels() async -> [ModelInfoResponse]
    func transcribe(audioData: Data, modelId: String) async throws -> TranscribeResponse
    func enhance(request: EnhanceRequest) async throws -> EnhanceResponse
    func listPrompts() async -> [PromptResponse]
    func createPrompt(_ request: CreatePromptRequest) async throws -> PromptResponse
    func deletePrompt(id: String) async throws
    func getSettings() async -> SettingsResponse
    func updateSettings(_ partial: [String: Any]) async throws
}
