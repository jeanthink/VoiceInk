import Foundation

public struct AIEnhancementOutputFilter {
    public init() {}
    
    public func filter(_ text: String) -> String {
        let patterns = [
            #"<thinking>[\s\S]*?</thinking>"#,
            #"<THINKING>[\s\S]*?</THINKING>"#,
            #"<think>[\s\S]*?</think>"#,
            #"<THINK>[\s\S]*?</THINK>"#,
            #"<reasoning>[\s\S]*?</reasoning>"#,
            #"<REASONING>[\s\S]*?</REASONING>"#
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
