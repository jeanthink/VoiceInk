import XCTest
@testable import VoiceInkCore

final class AIEnhancementOutputFilterTests: XCTestCase {
    var filter: AIEnhancementOutputFilter!
    
    override func setUp() {
        super.setUp()
        filter = AIEnhancementOutputFilter()
    }
    
    func testRemovesThinkingTags() {
        let input = "<thinking>This is internal reasoning</thinking>The actual output"
        let expected = "The actual output"
        XCTAssertEqual(filter.filter(input), expected)
    }
    
    func testRemovesReasoningTags() {
        let input = "Some text<reasoning>Internal logic here</reasoning>More text"
        let expected = "Some textMore text"
        XCTAssertEqual(filter.filter(input), expected)
    }
    
    func testRemovesMultipleTags() {
        let input = "<thinking>Think 1</thinking>Text<reasoning>Reason</reasoning>End"
        let expected = "TextEnd"
        XCTAssertEqual(filter.filter(input), expected)
    }
    
    func testHandlesCaseInsensitiveTags() {
        let input = "<THINKING>uppercase</THINKING><think>lowercase</think>Result"
        let expected = "Result"
        XCTAssertEqual(filter.filter(input), expected)
    }
    
    func testTrimsWhitespace() {
        let input = "  <thinking>Hidden</thinking>  Text  "
        let expected = "Text"
        XCTAssertEqual(filter.filter(input), expected)
    }
    
    func testLeavesCleanTextUnchanged() {
        let input = "This is clean text without tags"
        XCTAssertEqual(filter.filter(input), input)
    }
}
