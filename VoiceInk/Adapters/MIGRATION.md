# macOS Adapter Migration Guide

This directory contains the adapter layer that isolates platform-specific macOS code
behind protocol interfaces. This is part of the Path A cross-platform strategy
(see `/DECISIONS.md`).

## What's here

```
Adapters/
├── Protocols/               # Swift protocol definitions
│   ├── IAudioCapture.swift
│   ├── IGlobalShortcut.swift
│   ├── IClipboardService.swift
│   ├── IPasteService.swift
│   ├── INotificationService.swift
│   └── ISecretStore.swift
├── macOS/                   # macOS implementations (one per protocol)
│   ├── CoreAudioCapture.swift       → delegates to Recorder.swift
│   ├── HotkeyManagerAdapter.swift   → wraps HotkeyManager.swift (read-only)
│   ├── NSPasteboardClipboard.swift  → delegates to ClipboardManager.swift
│   ├── CGEventPaster.swift          → delegates to CursorPaster.swift
│   ├── AppNotificationAdapter.swift → delegates to NotificationManager.swift
│   └── KeychainSecretStore.swift    → delegates to KeychainService.swift
└── AdapterContainer.swift   # DI container — wire once in AppDelegate
```

## How to use

In `AppDelegate.swift`, construct an `AdapterContainer` once and pass it into
anything that needs platform services:

```swift
// In AppDelegate or your app's composition root:
let adapters = AdapterContainer.makeMacOS(
    recorder: myRecorder,
    hotkeyManager: myHotkeyManager  // optional
)

// Consumers depend only on the protocol:
func transcribe(with audio: IAudioCapture) { ... }
transcribe(with: adapters.audioCapture)

// Hotkey adapter is optional (see Design Notes for limitations):
if let hotkey = adapters.hotkey {
    print("Hotkey mode: \(hotkey.mode)")
}
```

## Migration status

| Protocol | macOS Adapter | Status |
|---|---|---|
| `IAudioCapture` | `CoreAudioCapture` | ✅ Complete — wraps Recorder + AudioDeviceManager |
| `IClipboardService` | `NSPasteboardClipboard` | ✅ Complete |
| `IPasteService` | `CGEventPaster` | ✅ Complete |
| `INotificationService` | `AppNotificationAdapter` | ✅ Complete |
| `ISecretStore` | `KeychainSecretStore` | ✅ Complete |
| `IGlobalShortcut` | `HotkeyManagerAdapter` | ⚠️ Partial — read-only wrapper (see notes below) |

## Design notes

- Each macOS adapter **delegates** to the existing implementation — it does not replace it.
  This keeps the diff minimal and avoids breaking existing behaviour.
- `AdapterContainer` is the only file that mentions concrete macOS types.
  All other call sites should refer to the protocol.

### IGlobalShortcut adapter limitations

`HotkeyManagerAdapter` is a **read-only wrapper** that exposes HotkeyManager's mode and
registration state but **cannot intercept activation callbacks**. This is because:

1. HotkeyManager is tightly coupled to `RecorderUIManager` — it directly calls
   `recorderUIManager.toggleMiniRecorder()` when hotkeys trigger.
2. The adapter cannot inject `onActivate`/`onDeactivate` callbacks without refactoring
   HotkeyManager to support callback injection.
3. Full IGlobalShortcut support requires:
   - Refactoring HotkeyManager to accept callbacks instead of directly calling RecorderUIManager
   - OR creating a notification/delegate pattern that the adapter can observe
   - OR accepting that IGlobalShortcut is only partially implemented on macOS

**Current status:** HotkeyManagerAdapter provides mode and registration control but
activation events remain tightly coupled to the existing UI layer. For VoiceInkCore
integration, consider making HotkeyManager callback-based in a future refactor.

## Next steps

1. **Add files to Xcode**: Open `VoiceInk.xcodeproj`, right-click the `VoiceInk/` group →
   _Add Files to "VoiceInk"_, select `VoiceInk/Adapters/` with _Create groups_.

2. **Rewire call sites**: Replace direct usage of `ClipboardManager`, `CursorPaster`,
   `KeychainService`, and `NotificationManager` with `AdapterContainer` injection.
   Leave HotkeyManager as-is (tightly coupled to RecorderUIManager).

3. **Create VoiceInkCore Swift Package** (tracked separately):
   - Extract business logic from macOS app
   - Move `Protocols/` to `VoiceInkCore/Sources/VoiceInkCore/Adapters/`
   - Add VoiceInkCore as local SPM dependency to Xcode project

4. **Wire VoiceInkCore to macOS app**:
   - Inject `AdapterContainer` into VoiceInkCore services
   - Update imports from `VoiceInk.Adapters.Protocols` to `VoiceInkCore`

5. **Future: Refactor HotkeyManager for callbacks** (optional):
   - Make HotkeyManager accept `onActivate`/`onDeactivate` callbacks
   - Remove direct RecorderUIManager coupling
   - Enable full IGlobalShortcut adapter implementation
