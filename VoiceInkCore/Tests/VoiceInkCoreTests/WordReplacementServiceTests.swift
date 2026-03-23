import XCTest
@testable import VoiceInkCore

final class WordReplacementServiceTests: XCTestCase {
    var engine: WordReplacementEngine!
    
    override func setUp() {
        super.setUp()
        engine = WordReplacementEngine()
    }
    
    func testBasicReplacement() {
        let replacements = [
            WordReplacement(originalText: "gonna", replacementText: "going to", isEnabled: true)
        ]
        
        let input = "I'm gonna go there"
        let result = engine.applyReplacements(to: input, using: replacements)
        XCTAssertEqual(result, "I'm going to go there")
    }
    
    func testCaseInsensitiveReplacement() {
        let replacements = [
            WordReplacement(originalText: "mac os", replacementText: "macOS", isEnabled: true)
        ]
        
        let input = "I use Mac OS on my computer"
        let result = engine.applyReplacements(to: input, using: replacements)
        XCTAssertTrue(result.contains("macOS"))
    }
    
    func testMultipleVariants() {
        let replacements = [
            WordReplacement(originalText: "gonna, gotta", replacementText: "going to", isEnabled: true)
        ]
        
        let input = "I gonna go and gotta leave"
        let result = engine.applyReplacements(to: input, using: replacements)
        XCTAssertTrue(result.contains("going to"))
        XCTAssertFalse(result.contains("gonna"))
        XCTAssertFalse(result.contains("gotta"))
    }
    
    func testDisabledReplacementsNotApplied() {
        let replacements = [
            WordReplacement(originalText: "test", replacementText: "replaced", isEnabled: false)
        ]
        
        let input = "This is a test"
        let result = engine.applyReplacements(to: input, using: replacements)
        XCTAssertEqual(result, input)
    }
    
    func testWordBoundaryRespected() {
        let replacements = [
            WordReplacement(originalText: "ai", replacementText: "AI", isEnabled: true)
        ]
        
        let input = "The ai is amazing"
        let result = engine.applyReplacements(to: input, using: replacements)
        XCTAssertTrue(result.contains("AI"))
        XCTAssertFalse(result.contains(" ai "))
    }
    
    func testEmptyReplacementsArrayReturnsOriginal() {
        let input = "No changes expected"
        let result = engine.applyReplacements(to: input, using: [])
        XCTAssertEqual(result, input)
    }
}
