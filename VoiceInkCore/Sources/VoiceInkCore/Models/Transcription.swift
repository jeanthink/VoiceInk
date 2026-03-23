import Foundation

public enum TranscriptionStatus: String, Codable {
    case pending
    case completed
    case failed
}

public struct Transcription: Identifiable, Codable {
    public let id: UUID
    public var text: String
    public var enhancedText: String?
    public let timestamp: Date
    public var duration: TimeInterval
    public var audioFileURL: String?
    public var transcriptionModelName: String?
    public var aiEnhancementModelName: String?
    public var promptName: String?
    public var transcriptionDuration: TimeInterval?
    public var enhancementDuration: TimeInterval?
    public var aiRequestSystemMessage: String?
    public var aiRequestUserMessage: String?
    public var powerModeName: String?
    public var powerModeEmoji: String?
    public var status: TranscriptionStatus
    
    public init(
        id: UUID = UUID(),
        text: String,
        duration: TimeInterval,
        enhancedText: String? = nil,
        audioFileURL: String? = nil,
        transcriptionModelName: String? = nil,
        aiEnhancementModelName: String? = nil,
        promptName: String? = nil,
        transcriptionDuration: TimeInterval? = nil,
        enhancementDuration: TimeInterval? = nil,
        aiRequestSystemMessage: String? = nil,
        aiRequestUserMessage: String? = nil,
        powerModeName: String? = nil,
        powerModeEmoji: String? = nil,
        status: TranscriptionStatus = .pending
    ) {
        self.id = id
        self.text = text
        self.enhancedText = enhancedText
        self.timestamp = Date()
        self.duration = duration
        self.audioFileURL = audioFileURL
        self.transcriptionModelName = transcriptionModelName
        self.aiEnhancementModelName = aiEnhancementModelName
        self.promptName = promptName
        self.transcriptionDuration = transcriptionDuration
        self.enhancementDuration = enhancementDuration
        self.aiRequestSystemMessage = aiRequestSystemMessage
        self.aiRequestUserMessage = aiRequestUserMessage
        self.powerModeName = powerModeName
        self.powerModeEmoji = powerModeEmoji
        self.status = status
    }
}
