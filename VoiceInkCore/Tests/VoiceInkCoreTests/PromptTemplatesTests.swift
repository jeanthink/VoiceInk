import XCTest
@testable import VoiceInkCore

final class PromptTemplatesTests: XCTestCase {
    func testAllTemplatesExist() {
        let templates = PromptTemplates.all
        XCTAssertFalse(templates.isEmpty)
        XCTAssertTrue(templates.count >= 4)
    }
    
    func testSystemDefaultTemplateExists() {
        let templates = PromptTemplates.all
        let systemDefault = templates.first { $0.title == "System Default" }
        
        XCTAssertNotNil(systemDefault)
        XCTAssertFalse(systemDefault!.promptText.isEmpty)
        XCTAssertEqual(systemDefault!.icon, "checkmark.seal.fill")
    }
    
    func testChatTemplateExists() {
        let templates = PromptTemplates.all
        let chat = templates.first { $0.title == "Chat" }
        
        XCTAssertNotNil(chat)
        XCTAssertTrue(chat!.promptText.contains("chat message"))
    }
    
    func testEmailTemplateExists() {
        let templates = PromptTemplates.all
        let email = templates.first { $0.title == "Email" }
        
        XCTAssertNotNil(email)
        XCTAssertTrue(email!.promptText.contains("email"))
    }
    
    func testTemplateToCustomPromptConversion() {
        let template = PromptTemplates.all.first!
        let customPrompt = template.toCustomPrompt()
        
        XCTAssertEqual(customPrompt.title, template.title)
        XCTAssertEqual(customPrompt.promptText, template.promptText)
        XCTAssertEqual(customPrompt.icon, template.icon)
        XCTAssertFalse(customPrompt.isPredefined)
    }
}

final class PredefinedPromptsTests: XCTestCase {
    func testPredefinedPromptsExist() {
        let prompts = PredefinedPrompts.all
        XCTAssertEqual(prompts.count, 2)
    }
    
    func testDefaultPromptExists() {
        let prompts = PredefinedPrompts.all
        let defaultPrompt = prompts.first { $0.id == PredefinedPrompts.defaultPromptId }
        
        XCTAssertNotNil(defaultPrompt)
        XCTAssertEqual(defaultPrompt!.title, "Default")
        XCTAssertTrue(defaultPrompt!.isPredefined)
        XCTAssertTrue(defaultPrompt!.useSystemInstructions)
    }
    
    func testAssistantPromptExists() {
        let prompts = PredefinedPrompts.all
        let assistant = prompts.first { $0.id == PredefinedPrompts.assistantPromptId }
        
        XCTAssertNotNil(assistant)
        XCTAssertEqual(assistant!.title, "Assistant")
        XCTAssertTrue(assistant!.isPredefined)
        XCTAssertFalse(assistant!.useSystemInstructions)
    }
}
