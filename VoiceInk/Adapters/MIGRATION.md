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
let adapters = AdapterContainer.makeMacOS(recorder: myRecorder)

// Consumers depend only on the protocol:
func transcribe(with audio: IAudioCapture) { ... }
transcribe(with: adapters.audioCapture)
```

## Migration status

| Protocol | macOS Adapter | Status |
|---|---|---|
| `IAudioCapture` | `CoreAudioCapture` | 🔧 Adapter created — wiring to call sites needed |
| `IClipboardService` | `NSPasteboardClipboard` | ✅ Complete |
| `IPasteService` | `CGEventPaster` | ✅ Complete |
| `INotificationService` | `AppNotificationAdapter` | ✅ Complete |
| `ISecretStore` | `KeychainSecretStore` | ✅ Complete |
| `IGlobalShortcut` | _(not yet)_ | 🚧 TODO — complex Carbon/AppKit wiring in HotkeyManager.swift |

## Design notes

- Each macOS adapter **delegates** to the existing implementation — it does not replace it.
  This keeps the diff minimal and avoids breaking existing behaviour.
- `AdapterContainer` is the only file that mentions concrete macOS types.
  All other call sites should refer to the protocol.
- `IGlobalShortcut` is intentionally left unimplemented. `HotkeyManager` uses
  `KeyboardShortcuts` (Carbon) with multiple named shortcuts and a push-to-talk
  state machine. The adapter needs careful mapping — tracked in a follow-up PR.

## Next steps

1. **Add files to Xcode**: Open `VoiceInk.xcodeproj`, right-click the `VoiceInk/` group →
   _Add Files to "VoiceInk"_, select `VoiceInk/Adapters/` with _Create groups_.
2. **Implement `IGlobalShortcut`**: Wrap `HotkeyManager.swift` behind the protocol.
3. **Rewire call sites**: Replace direct usage of `ClipboardManager`, `CursorPaster`,
   `KeychainService`, and `NotificationManager` with `AdapterContainer` injection.
4. **Migrate protocols to VoiceInkCore**: Once Naomi's `VoiceInkCore` PR merges,
   move `Protocols/` to `VoiceInkCore/Sources/VoiceInkCore/Adapters/` and update imports.
