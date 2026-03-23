import Foundation

public struct FillerWord: Identifiable, Codable {
    public let id: UUID
    public var word: String
    
    public init(id: UUID = UUID(), word: String) {
        self.id = id
        self.word = word
    }
}

public struct FillerWordConfig: Codable {
    public var fillerWords: [String]
    public var isEnabled: Bool
    
    public init(fillerWords: [String] = [], isEnabled: Bool = true) {
        self.fillerWords = fillerWords
        self.isEnabled = isEnabled
    }
    
    public static let defaultFillerWords = [
        "um", "uh", "er", "ah", "mm", "hmm", "like", "you know", "I mean",
        "sort of", "kind of", "basically", "actually", "literally",
        "right", "okay", "so", "well", "yeah"
    ]
}

public struct TranscriptionOutputFilter {
    private let hallucinationPatterns = [
        #"\[.*?\]"#,
        #"\(.*?\)"#,
        #"\{.*?\}"#
    ]
    
    public init() {}
    
    public func filter(_ text: String, config: FillerWordConfig) -> String {
        var filteredText = text
        
        // Remove <TAG>...</TAG> blocks
        let tagBlockPattern = #"<([A-Za-z][A-Za-z0-9:_-]*)[^>]*>[\s\S]*?</\1>"#
        if let regex = try? NSRegularExpression(pattern: tagBlockPattern) {
            let range = NSRange(filteredText.startIndex..., in: filteredText)
            filteredText = regex.stringByReplacingMatches(in: filteredText, options: [], range: range, withTemplate: "")
        }
        
        // Remove bracketed hallucinations
        for pattern in hallucinationPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(filteredText.startIndex..., in: filteredText)
                filteredText = regex.stringByReplacingMatches(in: filteredText, options: [], range: range, withTemplate: "")
            }
        }
        
        // Remove filler words (if enabled)
        if config.isEnabled {
            for fillerWord in config.fillerWords {
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: fillerWord))\\b[,.]?"
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(filteredText.startIndex..., in: filteredText)
                    filteredText = regex.stringByReplacingMatches(in: filteredText, options: [], range: range, withTemplate: "")
                }
            }
        }
        
        // Clean whitespace
        filteredText = filteredText.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        filteredText = filteredText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return filteredText
    }
    
    public func removeReasoningTags(_ text: String) -> String {
        let patterns = [
            #"<reasoning>[\s\S]*?</reasoning>"#,
            #"<REASONING>[\s\S]*?</REASONING>"#,
            #"<think>[\s\S]*?</think>"#,
            #"<THINK>[\s\S]*?</THINK>"#
        ]
        
        var result = text
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            }
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
