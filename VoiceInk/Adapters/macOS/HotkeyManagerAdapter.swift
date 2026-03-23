import Foundation

/// macOS implementation of IGlobalShortcut.
/// Wraps HotkeyManager's primary hotkey (hotkey1) to provide a simpler
/// protocol interface. The full HotkeyManager complexity (multiple hotkeys,
/// middle-click, Fn debouncing, KeyboardShortcuts framework) remains intact;
/// this adapter exposes only the primary hotkey behavior via callbacks.
@MainActor
public final class HotkeyManagerAdapter: IGlobalShortcut {
    
    private let hotkeyManager: HotkeyManager
    
    public var onActivate: (() -> Void)?
    public var onDeactivate: (() -> Void)?
    
    public init(hotkeyManager: HotkeyManager) {
        self.hotkeyManager = hotkeyManager
    }
    
    public var mode: ShortcutMode {
        get {
            switch hotkeyManager.hotkeyMode1 {
            case .toggle:
                return .toggle
            case .pushToTalk:
                return .pushToTalk
            case .hybrid:
                return .hybrid
            }
        }
        set {
            switch newValue {
            case .toggle:
                hotkeyManager.hotkeyMode1 = .toggle
            case .pushToTalk:
                hotkeyManager.hotkeyMode1 = .pushToTalk
            case .hybrid:
                hotkeyManager.hotkeyMode1 = .hybrid
            }
        }
    }
    
    public func register() throws {
        // HotkeyManager sets up monitoring in init and via setupHotkeyMonitoring.
        // The adapter doesn't need to do anything here — the manager is already active.
        // Throw an error if the selected hotkey is .none (not configured).
        guard hotkeyManager.selectedHotkey1 != .none else {
            throw HotkeyError.noHotkeyConfigured
        }
    }
    
    public func unregister() {
        // To unregister, set hotkey1 to .none. This triggers setupHotkeyMonitoring
        // which removes event monitors when no hotkeys are active.
        hotkeyManager.selectedHotkey1 = .none
    }
    
    public var isRegistered: Bool {
        return hotkeyManager.selectedHotkey1 != .none
    }
}

enum HotkeyError: Error {
    case noHotkeyConfigured
}
