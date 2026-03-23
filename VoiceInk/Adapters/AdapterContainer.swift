import Foundation

/// Holds all platform adapter instances.
/// Constructed once at app startup and injected where needed.
/// This is the single place where macOS-specific types are named — all other
/// call sites depend only on the protocol interfaces.
@MainActor
public final class AdapterContainer {
    public let audioCapture: IAudioCapture
    public let clipboard: IClipboardService
    public let paste: IPasteService
    public let notifications: INotificationService
    public let secrets: ISecretStore
    
    /// Optional hotkey adapter — see MIGRATION.md for limitations.
    /// HotkeyManager is tightly coupled to RecorderUIManager, so onActivate/onDeactivate
    /// callbacks cannot be intercepted. Use this for mode/registration control only.
    public let hotkey: IGlobalShortcut?

    public init(
        audioCapture: IAudioCapture,
        clipboard: IClipboardService,
        paste: IPasteService,
        notifications: INotificationService,
        secrets: ISecretStore,
        hotkey: IGlobalShortcut? = nil
    ) {
        self.audioCapture = audioCapture
        self.clipboard = clipboard
        self.paste = paste
        self.notifications = notifications
        self.secrets = secrets
        self.hotkey = hotkey
    }

    /// Construct the standard macOS adapter set.
    public static func makeMacOS(
        recorder: Recorder,
        hotkeyManager: HotkeyManager? = nil
    ) -> AdapterContainer {
        return AdapterContainer(
            audioCapture: CoreAudioCapture(recorder: recorder),
            clipboard: NSPasteboardClipboard(),
            paste: CGEventPaster(),
            notifications: AppNotificationAdapter(),
            secrets: KeychainSecretStore(),
            hotkey: hotkeyManager.map { HotkeyManagerAdapter(hotkeyManager: $0) }
        )
    }
}
