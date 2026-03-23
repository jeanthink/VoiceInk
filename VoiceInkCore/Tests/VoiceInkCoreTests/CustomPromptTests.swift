import XCTest
@testable import VoiceInkCore

final class CustomPromptTests: XCTestCase {
    func testBasicInit() {
        let prompt = CustomPrompt(
            title: "Test Prompt",
            promptText: "Do something",
            isActive: true
        )
        
        XCTAssertEqual(prompt.title, "Test Prompt")
        XCTAssertEqual(prompt.promptText, "Do something")
        XCTAssertTrue(prompt.isActive)
        XCTAssertEqual(prompt.icon, "doc.text.fill")
        XCTAssertFalse(prompt.isPredefined)
    }
    
    func testJSONEncoding() throws {
        let prompt = CustomPrompt(
            id: UUID(),
            title: "Email",
            promptText: "Write professionally",
            isActive: false,
            icon: "envelope.fill",
            description: "Professional emails",
            isPredefined: false,
            triggerWords: ["email", "write"],
            useSystemInstructions: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(prompt)
        
        XCTAssertFalse(data.isEmpty)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CustomPrompt.self, from: data)
        
        XCTAssertEqual(decoded.id, prompt.id)
        XCTAssertEqual(decoded.title, prompt.title)
        XCTAssertEqual(decoded.promptText, prompt.promptText)
        XCTAssertEqual(decoded.isActive, prompt.isActive)
        XCTAssertEqual(decoded.icon, prompt.icon)
        XCTAssertEqual(decoded.description, prompt.description)
        XCTAssertEqual(decoded.isPredefined, prompt.isPredefined)
        XCTAssertEqual(decoded.triggerWords, prompt.triggerWords)
        XCTAssertEqual(decoded.useSystemInstructions, prompt.useSystemInstructions)
    }
    
    func testFinalPromptTextWithSystemInstructions() {
        let prompt = CustomPrompt(
            title: "Test",
            promptText: "Be concise",
            useSystemInstructions: true
        )
        
        let finalText = prompt.finalPromptText()
        XCTAssertTrue(finalText.contains("Be concise"))
        XCTAssertTrue(finalText.contains("SYSTEM_INSTRUCTIONS"))
    }
    
    func testFinalPromptTextWithoutSystemInstructions() {
        let prompt = CustomPrompt(
            title: "Test",
            promptText: "Raw prompt text",
            useSystemInstructions: false
        )
        
        let finalText = prompt.finalPromptText()
        XCTAssertEqual(finalText, "Raw prompt text")
    }
    
    func testEquality() {
        let id = UUID()
        let prompt1 = CustomPrompt(id: id, title: "Test", promptText: "Text")
        let prompt2 = CustomPrompt(id: id, title: "Test", promptText: "Text")
        
        XCTAssertEqual(prompt1, prompt2)
    }
}
