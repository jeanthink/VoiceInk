import Foundation

/// Stub implementation of CoreBridgeProtocol for testing and development.
/// Returns predictable mock responses without requiring VoiceInkCore.
public final class StubCoreBridge: CoreBridgeProtocol {

    public init() {}

    public func health() async -> HealthResponse {
        HealthResponse(status: "ok (stub)", version: "1.0.0-stub")
    }

    public func listModels() async -> [ModelInfoResponse] {
        [
            ModelInfoResponse(id: "whisper-tiny", name: "Whisper Tiny", provider: "local", isLocal: true, isAvailable: true),
            ModelInfoResponse(id: "whisper-base", name: "Whisper Base", provider: "local", isLocal: true, isAvailable: false),
            ModelInfoResponse(id: "gpt-4o-audio", name: "GPT-4o Audio", provider: "openai", isLocal: false, isAvailable: false),
        ]
    }

    public func transcribe(audioData: Data, modelId: String) async throws -> TranscribeResponse {
        try await Task.sleep(nanoseconds: 500_000_000)
        return TranscribeResponse(
            text: "This is a stub transcription of \(audioData.count) bytes of audio.",
            duration: 0.5,
            confidence: 0.99,
            modelId: modelId
        )
    }

    public func enhance(request: EnhanceRequest) async throws -> EnhanceResponse {
        try await Task.sleep(nanoseconds: 200_000_000)
        return EnhanceResponse(
            enhancedText: "[Enhanced] \(request.text)",
            model: "stub-llm"
        )
    }

    public func listPrompts() async -> [PromptResponse] {
        [
            PromptResponse(id: "general", title: "General", promptText: "Clean up this transcription.", icon: "✨", triggerWords: [], isBuiltIn: true),
            PromptResponse(id: "email", title: "Email", promptText: "Format this as a professional email.", icon: "📧", triggerWords: ["email", "mail"], isBuiltIn: true),
        ]
    }

    public func createPrompt(_ request: CreatePromptRequest) async throws -> PromptResponse {
        PromptResponse(
            id: UUID().uuidString,
            title: request.title,
            promptText: request.promptText,
            icon: request.icon ?? "💬",
            triggerWords: request.triggerWords ?? [],
            isBuiltIn: false
        )
    }

    public func deletePrompt(id: String) async throws {
        // stub — do nothing
    }

    public func getSettings() async -> SettingsResponse {
        SettingsResponse(
            selectedTranscriptionModelId: "whisper-tiny",
            selectedEnhancementModelId: nil,
            isEnhancementEnabled: false,
            defaultPromptId: "general",
            ollamaBaseUrl: "http://localhost:11434"
        )
    }

    public func updateSettings(_ partial: [String: Any]) async throws {
        // stub — do nothing
    }
}
