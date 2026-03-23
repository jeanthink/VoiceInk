import Foundation

public struct VocabularyWord: Identifiable, Codable {
    public let id: UUID
    public var word: String
    public var dateAdded: Date
    
    public init(id: UUID = UUID(), word: String, dateAdded: Date = Date()) {
        self.id = id
        self.word = word
        self.dateAdded = dateAdded
    }
}
