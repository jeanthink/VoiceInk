import Foundation

// MARK: - Audio Capture
public protocol IAudioCapture {
    func startRecording() async throws
    func stopRecording() async throws -> Data
    var isRecording: Bool { get }
}

// MARK: - Clipboard Service
public protocol IClipboardService {
    func getContents() -> String?
    func setContents(_ text: String)
}

// MARK: - Context Provider
public protocol IContextProvider {
    func getCurrentWindowTitle() async -> String?
    func getSelectedText() async -> String?
}

// MARK: - Global Shortcut
public protocol IGlobalShortcut {
    func register(keyCode: UInt16, modifiers: UInt32, handler: @escaping () -> Void) -> Bool
    func unregister()
}

// MARK: - Notification Service
public protocol INotificationService {
    func show(title: String, message: String)
    func showError(title: String, message: String)
}

// MARK: - Paste Service
public protocol IPasteService {
    func paste(_ text: String) async throws
}

// MARK: - Secret Store
public protocol ISecretStore {
    func store(key: String, value: String) throws
    func retrieve(key: String) throws -> String?
    func delete(key: String) throws
}
