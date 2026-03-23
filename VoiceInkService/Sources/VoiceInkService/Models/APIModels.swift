import Foundation
import Vapor

// MARK: - Health

struct HealthResponse: Content {
    let status: String
    let version: String
    let timestamp: Date
}

// MARK: - Transcription

struct TranscriptionRequest: Content {
    let audioData: Data?
    let language: String?
    let model: String?
}

struct TranscriptionResponse: Content {
    let text: String
    let language: String?
    let duration: Double?
    let model: String
}

struct ModelInfo: Content {
    let id: String
    let name: String
    let type: String // "local" or "cloud"
    let provider: String
    let available: Bool
}

struct ModelsListResponse: Content {
    let models: [ModelInfo]
}

// MARK: - Enhancement

struct EnhancementRequest: Content {
    let text: String
    let promptId: String?
    let systemPrompt: String?
    let model: String
    let temperature: Double?
    let maxTokens: Int?
}

struct EnhancementResponse: Content {
    let originalText: String
    let enhancedText: String
    let model: String
    let promptUsed: String?
    let tokensUsed: Int?
}

struct PromptInfo: Content {
    let id: String
    let name: String
    let description: String
    let systemPrompt: String
    let category: String?
}

struct PromptsListResponse: Content {
    let prompts: [PromptInfo]
}

// MARK: - Error Response

struct ErrorResponse: Content {
    let error: Bool
    let message: String
    let code: String?
}
