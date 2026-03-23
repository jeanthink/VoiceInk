import Foundation

// MARK: - Health

public struct HealthResponse: Codable {
    public let status: String
    public let version: String

    public init(status: String = "ok", version: String = "1.0.0") {
        self.status = status
        self.version = version
    }
}

// MARK: - Models

public struct ModelInfoResponse: Codable {
    public let id: String
    public let name: String
    public let provider: String
    public let isLocal: Bool
    public let isAvailable: Bool
}

// MARK: - Transcription

public struct TranscribeResponse: Codable {
    public let text: String
    public let duration: Double
    public let confidence: Double
    public let modelId: String
}

// MARK: - Enhancement

public struct EnhanceRequest: Codable {
    public let text: String
    public let promptId: String?
    public let customPrompt: String?
    public let context: ContextInfo?

    public struct ContextInfo: Codable {
        public let selectedText: String?
        public let activeUrl: String?
        public let screenText: String?
    }
}

public struct EnhanceResponse: Codable {
    public let enhancedText: String
    public let model: String
}

// MARK: - Prompts

public struct PromptResponse: Codable {
    public let id: String
    public let title: String
    public let promptText: String
    public let icon: String
    public let triggerWords: [String]
    public let isBuiltIn: Bool
}

public struct CreatePromptRequest: Codable {
    public let title: String
    public let promptText: String
    public let icon: String?
    public let triggerWords: [String]?
}

// MARK: - Settings

public struct SettingsResponse: Codable {
    public let selectedTranscriptionModelId: String?
    public let selectedEnhancementModelId: String?
    public let isEnhancementEnabled: Bool
    public let defaultPromptId: String?
    public let ollamaBaseUrl: String
}

// MARK: - Error

public struct ErrorResponse: Codable {
    public let error: String
    public let code: Int

    public init(_ message: String, code: Int = 400) {
        self.error = message
        self.code = code
    }
}
