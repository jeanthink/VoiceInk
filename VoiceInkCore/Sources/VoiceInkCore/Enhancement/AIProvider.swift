import Foundation

public enum AIProvider: String, Codable, CaseIterable {
    case ollama
    case openAI
    case groq
    case openRouter
    case anthropic
    case gemini
    case xai
    case deepSeek
    case mistral
    case together
    case cerebras
    
    public var displayName: String {
        switch self {
        case .ollama: return "Ollama"
        case .openAI: return "OpenAI"
        case .groq: return "Groq"
        case .openRouter: return "OpenRouter"
        case .anthropic: return "Anthropic"
        case .gemini: return "Google Gemini"
        case .xai: return "xAI"
        case .deepSeek: return "DeepSeek"
        case .mistral: return "Mistral"
        case .together: return "Together AI"
        case .cerebras: return "Cerebras"
        }
    }
    
    public var requiresAPIKey: Bool {
        return self != .ollama
    }
    
    public var baseURL: String {
        switch self {
        case .ollama: return "http://localhost:11434"
        case .openAI: return "https://api.openai.com/v1"
        case .groq: return "https://api.groq.com/openai/v1"
        case .openRouter: return "https://openrouter.ai/api/v1"
        case .anthropic: return "https://api.anthropic.com/v1"
        case .gemini: return "https://generativelanguage.googleapis.com/v1beta"
        case .xai: return "https://api.x.ai/v1"
        case .deepSeek: return "https://api.deepseek.com/v1"
        case .mistral: return "https://api.mistral.ai/v1"
        case .together: return "https://api.together.xyz/v1"
        case .cerebras: return "https://api.cerebras.ai/v1"
        }
    }
}

public struct AIModel: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let provider: AIProvider
    public let contextWindow: Int?
    
    public init(id: String, name: String, provider: AIProvider, contextWindow: Int? = nil) {
        self.id = id
        self.name = name
        self.provider = provider
        self.contextWindow = contextWindow
    }
}

public enum AIError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case invalidAPIKey
    case rateLimitExceeded
    case modelNotAvailable
    case invalidResponse
    case providerError(String)
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .modelNotAvailable:
            return "Selected model is not available"
        case .invalidResponse:
            return "Invalid response from AI provider"
        case .providerError(let message):
            return "Provider error: \(message)"
        case .cancelled:
            return "Request was cancelled"
        }
    }
}
