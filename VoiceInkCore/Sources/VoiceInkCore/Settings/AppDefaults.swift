import Foundation

public struct AppDefaults {
    // AI Enhancement
    public static let aiProvider = "aiProvider"
    public static let selectedAIModel = "selectedAIModel"
    public static let temperature = "temperature"
    public static let selectedPromptId = "selectedPromptId"
    public static let customPrompts = "customPrompts"
    
    // Ollama
    public static let ollamaBaseURL = "ollamaBaseURL"
    public static let ollamaSelectedModel = "ollamaSelectedModel"
    
    // Filler Words
    public static let fillerWordsEnabled = "fillerWordsEnabled"
    public static let customFillerWords = "customFillerWords"
    
    // Transcription
    public static let selectedTranscriptionModel = "selectedTranscriptionModel"
    public static let transcriptionProvider = "transcriptionProvider"
    
    // Context
    public static let includeClipboardContext = "includeClipboardContext"
    public static let includeWindowContext = "includeWindowContext"
    public static let includeSelectedTextContext = "includeSelectedTextContext"
    public static let includeCustomVocabulary = "includeCustomVocabulary"
    
    public init() {}
}
