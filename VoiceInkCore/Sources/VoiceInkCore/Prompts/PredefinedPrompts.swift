import Foundation

public enum PredefinedPrompts {
    public static let defaultPromptId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    public static let assistantPromptId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    
    public static var all: [CustomPrompt] {
        createDefaultPrompts()
    }
    
    public static func createDefaultPrompts() -> [CustomPrompt] {
        [
            CustomPrompt(
                id: defaultPromptId,
                title: "Default",
                promptText: PromptTemplates.all.first { $0.title == "System Default" }?.promptText ?? "",
                icon: "checkmark.seal.fill",
                description: "Default mode to improved clarity and accuracy of the transcription",
                isPredefined: true,
                useSystemInstructions: true
            ),
            CustomPrompt(
                id: assistantPromptId,
                title: "Assistant",
                promptText: AIPrompts.assistantMode,
                icon: "bubble.left.and.bubble.right.fill",
                description: "AI assistant that provides direct answers to queries",
                isPredefined: true,
                useSystemInstructions: false
            )
        ]
    }
}
