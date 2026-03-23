import Foundation
// import VoiceInkCore  // Uncomment when Naomi's PR is merged

/// Production implementation of CoreBridgeProtocol using VoiceInkCore.
/// This is where the real transcription, enhancement, and prompt management happen.
public final class VoiceInkCoreBridge: CoreBridgeProtocol {

    // TODO: Initialize VoiceInkCore services here
    // private let transcriptionRegistry: TranscriptionServiceRegistry
    // private let enhancementService: AIEnhancementService
    // private let promptRegistry: PromptRegistry

    public init() {
        // TODO: Initialize when VoiceInkCore is available
    }

    public func health() async -> HealthResponse {
        HealthResponse()
    }

    public func listModels() async -> [ModelInfoResponse] {
        // TODO: Call VoiceInkCore.TranscriptionServiceRegistry.availableModels
        return []
    }

    public func transcribe(audioData: Data, modelId: String) async throws -> TranscribeResponse {
        // TODO: Call VoiceInkCore transcription pipeline
        throw NSError(domain: "VoiceInkService", code: 501, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented — VoiceInkCore not wired"])
    }

    public func enhance(request: EnhanceRequest) async throws -> EnhanceResponse {
        // TODO: Call VoiceInkCore.AIEnhancementService
        throw NSError(domain: "VoiceInkService", code: 501, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented — VoiceInkCore not wired"])
    }

    public func listPrompts() async -> [PromptResponse] {
        // TODO: Call VoiceInkCore.PromptRegistry
        return []
    }

    public func createPrompt(_ request: CreatePromptRequest) async throws -> PromptResponse {
        throw NSError(domain: "VoiceInkService", code: 501, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented"])
    }

    public func deletePrompt(id: String) async throws {
        throw NSError(domain: "VoiceInkService", code: 501, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented"])
    }

    public func getSettings() async -> SettingsResponse {
        SettingsResponse(
            selectedTranscriptionModelId: nil,
            selectedEnhancementModelId: nil,
            isEnhancementEnabled: false,
            defaultPromptId: nil,
            ollamaBaseUrl: "http://localhost:11434"
        )
    }

    public func updateSettings(_ partial: [String: Any]) async throws {
        // TODO
    }
}
