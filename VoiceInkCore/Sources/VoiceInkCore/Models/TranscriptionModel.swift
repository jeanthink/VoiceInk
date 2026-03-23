import Foundation

public struct TranscriptionModel: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let provider: String
    public let isLocal: Bool
    public let requiresAPIKey: Bool
    
    public init(id: String, name: String, provider: String, isLocal: Bool, requiresAPIKey: Bool) {
        self.id = id
        self.name = name
        self.provider = provider
        self.isLocal = isLocal
        self.requiresAPIKey = requiresAPIKey
    }
}
