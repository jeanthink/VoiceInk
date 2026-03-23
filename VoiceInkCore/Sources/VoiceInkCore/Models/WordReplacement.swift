import Foundation

public struct WordReplacement: Identifiable, Codable {
    public let id: UUID
    public var originalText: String
    public var replacementText: String
    public var dateAdded: Date
    public var isEnabled: Bool
    
    public init(
        id: UUID = UUID(),
        originalText: String,
        replacementText: String,
        dateAdded: Date = Date(),
        isEnabled: Bool = true
    ) {
        self.id = id
        self.originalText = originalText
        self.replacementText = replacementText
        self.dateAdded = dateAdded
        self.isEnabled = isEnabled
    }
}
