import XCTest
@testable import VoiceInkCore

final class TranscriptionOutputFilterTests: XCTestCase {
    var filter: TranscriptionOutputFilter!
    var config: FillerWordConfig!
    
    override func setUp() {
        super.setUp()
        filter = TranscriptionOutputFilter()
        config = FillerWordConfig(
            fillerWords: ["um", "uh", "like"],
            isEnabled: true
        )
    }
    
    func testRemovesTagBlocks() {
        let input = "Text <div>content</div> more"
        let result = filter.filter(input, config: config)
        XCTAssertEqual(result, "Text more")
    }
    
    func testRemovesBracketedContent() {
        let input = "Text [bracketed] (parenthesized) {braced}"
        let result = filter.filter(input, config: config)
        XCTAssertTrue(result.isEmpty || result.trimmingCharacters(in: .whitespaces) == "Text")
    }
    
    func testRemovesFillerWords() {
        let input = "Um, I think like this is uh good"
        let result = filter.filter(input, config: config)
        XCTAssertFalse(result.contains("um"))
        XCTAssertFalse(result.contains("Um"))
        XCTAssertFalse(result.contains("uh"))
        XCTAssertFalse(result.contains("like"))
    }
    
    func testDoesNotRemoveFillerWordsWhenDisabled() {
        config.isEnabled = false
        let input = "Um, I think like this"
        let result = filter.filter(input, config: config)
        XCTAssertTrue(result.contains("Um") || result.contains("um"))
    }
    
    func testCleansExtraWhitespace() {
        let input = "Text    with     extra     spaces"
        let result = filter.filter(input, config: config)
        XCTAssertFalse(result.contains("    "))
        XCTAssertTrue(result.contains("Text with extra spaces"))
    }
    
    func testRemovesReasoningTags() {
        let input = "<reasoning>Hidden thinking</reasoning>Visible output"
        let result = filter.removeReasoningTags(input)
        XCTAssertEqual(result, "Visible output")
    }
    
    func testRemovesMultipleReasoningTags() {
        let input = "<think>First</think>Text<REASONING>Second</REASONING>End"
        let result = filter.removeReasoningTags(input)
        XCTAssertEqual(result, "TextEnd")
    }
}
