import Foundation

public struct VocabularyFormatter {
    public init() {}
    
    public func formatVocabularyForPrompt(_ words: [String]) -> String {
        guard !words.isEmpty else {
            return ""
        }
        
        let wordsText = words.joined(separator: ", ")
        return "<CUSTOM_VOCABULARY>\n\(wordsText)\n</CUSTOM_VOCABULARY>"
    }
    
    public func formatContextForPrompt(clipboard: String?, windowTitle: String?) -> String {
        var context = ""
        
        if let clipboard = clipboard, !clipboard.isEmpty {
            context += "<CLIPBOARD_CONTEXT>\n\(clipboard)\n</CLIPBOARD_CONTEXT>\n\n"
        }
        
        if let windowTitle = windowTitle, !windowTitle.isEmpty {
            context += "<CURRENT_WINDOW_CONTEXT>\n\(windowTitle)\n</CURRENT_WINDOW_CONTEXT>\n\n"
        }
        
        return context
    }
    
    public func wrapTranscript(_ text: String) -> String {
        return "<TRANSCRIPT>\n\(text)\n</TRANSCRIPT>"
    }
}
