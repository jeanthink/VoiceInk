import XCTest
@testable import VoiceInkCore

final class AIProviderTests: XCTestCase {
    func testAllProvidersHaveDisplayNames() {
        for provider in AIProvider.allCases {
            XCTAssertFalse(provider.displayName.isEmpty)
        }
    }
    
    func testAllProvidersHaveBaseURLs() {
        for provider in AIProvider.allCases {
            XCTAssertFalse(provider.baseURL.isEmpty)
            XCTAssertNotNil(URL(string: provider.baseURL))
        }
    }
    
    func testOllamaDoesNotRequireAPIKey() {
        XCTAssertFalse(AIProvider.ollama.requiresAPIKey)
    }
    
    func testCloudProvidersRequireAPIKey() {
        XCTAssertTrue(AIProvider.openAI.requiresAPIKey)
        XCTAssertTrue(AIProvider.anthropic.requiresAPIKey)
        XCTAssertTrue(AIProvider.groq.requiresAPIKey)
    }
}

final class ReasoningConfigTests: XCTestCase {
    func testO1ModelsGetReasoningEffort() {
        XCTAssertEqual(ReasoningConfig.getReasoningEffort(for: "o1-preview"), "medium")
        XCTAssertEqual(ReasoningConfig.getReasoningEffort(for: "o1-mini"), "medium")
    }
    
    func testO3ModelsGetReasoningEffort() {
        XCTAssertEqual(ReasoningConfig.getReasoningEffort(for: "o3-mini"), "medium")
    }
    
    func testRegularModelsDoNotGetReasoningEffort() {
        XCTAssertNil(ReasoningConfig.getReasoningEffort(for: "gpt-4"))
        XCTAssertNil(ReasoningConfig.getReasoningEffort(for: "claude-3"))
    }
    
    func testSupportsReasoningDetection() {
        XCTAssertTrue(ReasoningConfig.supportsReasoning("o1-preview"))
        XCTAssertTrue(ReasoningConfig.supportsReasoning("o3-mini"))
        XCTAssertFalse(ReasoningConfig.supportsReasoning("gpt-4"))
    }
    
    func testExtraBodyForReasoningModels() {
        let body = ReasoningConfig.getExtraBody(for: "o1-preview")
        XCTAssertNotNil(body)
        XCTAssertEqual(body?["reasoning_effort"] as? String, "medium")
    }
}
