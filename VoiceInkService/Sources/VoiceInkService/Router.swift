import Foundation

/// Route definitions for VoiceInkService.
/// Maps HTTP method + path to handler functions.
/// TODO: Implement with a real HTTP framework (swift-nio or Vapor)
public final class Router {
    let bridge: CoreBridgeProtocol

    public init(bridge: CoreBridgeProtocol) {
        self.bridge = bridge
    }

    // Route table — for documentation and future implementation
    // GET  /health         → HealthHandler.handle
    // GET  /models         → ModelsHandler.handle
    // POST /transcribe     → TranscribeHandler.handle
    // POST /enhance        → EnhanceHandler.handle
    // GET  /prompts        → PromptsHandler.listPrompts
    // POST /prompts        → PromptsHandler.createPrompt
    // DELETE /prompts/:id  → PromptsHandler.deletePrompt
    // GET  /settings       → SettingsHandler.getSettings
    // PATCH /settings      → SettingsHandler.updateSettings
}
