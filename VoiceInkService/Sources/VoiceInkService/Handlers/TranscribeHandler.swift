import Foundation

public struct TranscribeHandler {
    /// Transcribe raw audio bytes using the specified model.
    static func handle(audioData: Data, modelId: String, bridge: CoreBridgeProtocol) async throws -> TranscribeResponse {
        try await bridge.transcribe(audioData: audioData, modelId: modelId)
    }
}
