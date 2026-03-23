# Cross-Platform Shell Architecture for VoiceInk

## Goal

Define the multi-platform application structure using Avalonia and a C# .NET shared core.

The purpose of this document is to establish the chosen framework, project layout, and per-platform adapter strategy so implementation can begin.

## Product Definition

VoiceInk should be a native desktop application on Windows, macOS, and Linux.

Each platform version should:

- record from the microphone
- run transcription
- run prompt rewriting through user-owned local models when selected
- insert or copy results into other apps
- integrate naturally with the platform's tray or menu bar conventions

No platform version should depend on cloud services as the primary path. The product identity is:

- privacy-focused
- local-model friendly
- prompt-engineering oriented

Windows speech APIs, macOS SpeechTranscriber, and Linux speech stacks are optional adapters, not the core path.

## Recommended Direction

The chosen architecture is: **Avalonia desktop shells** wrapping a **C# .NET shared core class library**.

### Chosen Framework: Avalonia

Avalonia is a desktop-first open-source .NET UI framework targeting Windows, macOS, and Linux from a single codebase. It is not mobile-focused, supports tray integration, custom window styles, and native-feel desktop behavior. It is the correct choice for a tray-based productivity desktop app.

MAUI (Microsoft's cross-platform framework) was evaluated and rejected for this use case because it is mobile-first, and its macOS desktop support is weak relative to Avalonia.

### Solution Layout

```
VoiceInk.sln
├── VoiceInk.Core          net9.0 class library — all product logic, no platform imports
├── VoiceInk.Adapters      net9.0 class library — interface definitions only
├── VoiceInk.Windows       net9.0-windows Avalonia app
├── VoiceInk.macOS         net9.0-macos Avalonia app
└── VoiceInk.Linux         net9.0 Avalonia app
```

### VoiceInk.Core Responsibilities

- transcription model selection
- provider routing
- prompt templates
- enhancement orchestration
- output filtering
- custom vocabulary injection
- model and prompt configuration rules
- Ollama and OpenAI-compatible HTTP backends

No platform SDK imports. No Avalonia imports.

### VoiceInk.Adapters Responsibilities

Defines the interfaces each shell must implement:

- `IAudioCapture`
- `IGlobalShortcut`
- `IClipboardService`
- `IPasteService`
- `INotificationService`
- `ISecretStore`
- `IContextProvider` (optional)

### Shell Responsibilities (per platform)

Each Avalonia shell:

- owns the Avalonia app lifecycle and window management
- implements all adapter interfaces using platform-native APIs
- provides tray or menu bar integration using OS conventions
- handles platform-specific permission and onboarding flows

## Why Not a Direct Swift Port

The current macOS app is organized around platform assumptions that do not carry over cleanly to any other OS:

- menu bar and AppKit window rules
- Carbon and NSEvent hotkey handling
- Core Audio and AUHAL capture setup
- AppleScript browser integration
- macOS accessibility-driven selected text behavior

That means the cross-platform product should be treated as a fresh C# rewrite of the business logic with per-platform adapter implementations, not as a line-by-line port of Swift to another language.

## Framework Evaluation

### Option A: Swift on Windows

Rejected. Swift on Windows is experimental, its desktop ecosystem is immature, and it cannot cleanly integrate with Windows tray, WASAPI, Win32 input injection, or Windows Credential Manager.

### Option B: MAUI

Rejected for this use case. MAUI is mobile-first. Its macOS desktop support is weaker than Avalonia, and it does not cover Linux. A productivity tray app with deep OS integration is a poor match for MAUI.

### Option C: Avalonia + C# .NET shared core ✅ Chosen

Avalonia is a desktop-first .NET UI framework with first-class support for Windows, macOS, and Linux. It renders using Skia (GPU-accelerated) and integrates with platform tray, windowing, and input systems.

Pros:

- one UI codebase for all three desktop targets
- desktop-first, not a mobile port
- `VoiceInk.Core` logic is shared transparently across all shells
- strong fit for tray apps, custom windowing, and OS-native adapter pattern
- active open-source community and commercial backing

Cons:

- some platform integrations still require per-platform native calls via P/Invoke
- advanced tray features differ slightly per OS and require testing

## Process Model

First release:

- one Avalonia desktop app process per platform
- `VoiceInk.Core` loaded as a library inside that process
- platform adapters injected into orchestration at startup

This keeps the initial release simpler than a multi-process architecture. If needed later, the AI core can move behind a local gRPC or HTTP service boundary for out-of-process hosting.

## Per-Platform Capability Map

### Required for MVP (all platforms)

- microphone capture
- global hotkey registration
- tray icon or menu bar extra
- clipboard read and write
- paste or text insertion
- system notifications
- secure secret storage

### Optional for Later (all platforms)

- selected text access
- active browser URL detection
- screen capture context
- deep browser context injection

These optional capabilities must not block any platform MVP release.

## Proposed Layering

### Layer 1: Avalonia Application Shell (per platform)

Responsibilities:

- startup and shutdown
- tray or menu bar lifecycle
- settings and onboarding windows
- permission and error UX

Swift reference behavior:

- [VoiceInk/MenuBarManager.swift](VoiceInk/MenuBarManager.swift)
- [VoiceInk/WindowManager.swift](VoiceInk/WindowManager.swift)
- [VoiceInk/AppDelegate.swift](VoiceInk/AppDelegate.swift)

### Layer 2: Platform Adapters (per platform, in each shell project)

Each shell implements every interface from `VoiceInk.Adapters`.

| Interface | Windows | macOS | Linux |
|---|---|---|---|
| `IAudioCapture` | WASAPI / NAudio | CoreAudio P/Invoke | PipeWire / ALSA |
| `IGlobalShortcut` | `RegisterHotKey` Win32 | CGEvent P/Invoke | XGrabKey / libinput |
| `IClipboardService` | Win32 Clipboard | NSPasteboard P/Invoke | X11 / Wayland data device |
| `IPasteService` | `SendInput` | CGEvent keyboard | ydotool / XSendEvent |
| `INotificationService` | Windows Toast | UserNotifications P/Invoke | D-Bus freedesktop |
| `ISecretStore` | DPAPI / Credential Manager | Keychain P/Invoke | libsecret / KWallet |

Swift reference behavior:

- [VoiceInk/Recorder.swift](VoiceInk/Recorder.swift)
- [VoiceInk/CoreAudioRecorder.swift](VoiceInk/CoreAudioRecorder.swift)
- [VoiceInk/HotkeyManager.swift](VoiceInk/HotkeyManager.swift)
- [VoiceInk/ClipboardManager.swift](VoiceInk/ClipboardManager.swift)
- [VoiceInk/CursorPaster.swift](VoiceInk/CursorPaster.swift)
- [VoiceInk/Notifications/NotificationManager.swift](VoiceInk/Notifications/NotificationManager.swift)
- [VoiceInk/Services/KeychainService.swift](VoiceInk/Services/KeychainService.swift)

### Layer 3: VoiceInk.Core (shared, platform-agnostic C#)

Responsibilities:

- transcription routing
- prompt selection
- rewrite orchestration
- output filtering
- vocabulary injection
- model selection
- Ollama and OpenAI-compatible HTTP calls

Swift reference behavior:

- [VoiceInk/Models/TranscriptionModel.swift](VoiceInk/Models/TranscriptionModel.swift)
- [VoiceInk/Services/TranscriptionServiceRegistry.swift](VoiceInk/Services/TranscriptionServiceRegistry.swift)
- [VoiceInk/Services/AIEnhancement/AIEnhancementService.swift](VoiceInk/Services/AIEnhancement/AIEnhancementService.swift)
- [VoiceInk/Services/AIEnhancement/AIService.swift](VoiceInk/Services/AIEnhancement/AIService.swift)
- [VoiceInk/Services/OllamaService.swift](VoiceInk/Services/OllamaService.swift)

### Layer 4: Optional Context Providers (per platform, post-MVP)

Each platform implements `IContextProvider` as an optional injectable.

| Capability | Windows | macOS | Linux |
|---|---|---|---|
| Selected text | UI Automation | Accessibility API | AT-SPI |
| Screen context | DXGI + OCR | ScreenCaptureKit + Vision | PipeWire + Tesseract |
| Browser URL | CDP or extension | CDP or extension | CDP or extension |

Swift reference behavior:

- [VoiceInk/Services/SelectedTextService.swift](VoiceInk/Services/SelectedTextService.swift)
- [VoiceInk/Services/ScreenCaptureService.swift](VoiceInk/Services/ScreenCaptureService.swift)
- [VoiceInk/PowerMode/BrowserURLService.swift](VoiceInk/PowerMode/BrowserURLService.swift)

## UX Conventions Per Platform

Do not copy macOS interaction patterns to other platforms. Design around each OS's conventions.

| macOS pattern | Windows equivalent | Linux equivalent |
|---|---|---|
| Menu bar extra | System tray icon | System notification area |
| Dock bounce / badge | Taskbar progress | No standard equivalent |
| NSPanel floating | Topmost floating Avalonia window | Floating Avalonia window |
| Accessibility permission prompt | UAC / microphone settings deep link | PulseAudio / PipeWire permission guidance |
| Fn / Option / Control hotkeys | Win key combinations or side keys | Meta / Alt / Ctrl combinations |

## Local Model Strategy (all platforms)

First-class local path, in priority order:

1. local rewrite models through Ollama-compatible servers — Ollama runs on Windows, macOS, and Linux
2. local transcription through whisper.cpp or equivalent local speech backends — whisper.cpp builds on all three platforms
3. platform speech APIs (Windows Speech, macOS SpeechTranscriber, etc.) — treated as optional adapters, not the primary path

This is the product-defining privacy and ownership story.

## Architecture Rules

1. `VoiceInk.Core` must not import Avalonia, platform SDKs, AppKit, WinRT, or any OS-specific library.
2. `VoiceInk.Adapters` must contain only interfaces and data types, no implementations.
3. Context providers (`IContextProvider`) are optional. Their absence must never cause a pipeline failure.
4. No platform shell may import another platform shell project.
5. Every MVP release on each platform must work without browser automation.
6. Every MVP release on each platform must work without selected text extraction.
7. Local-only mode must not require any cloud provider or internet connection.
8. Adding a new local LLM backend requires only a new class in `VoiceInk.Core` implementing `ILocalLLMBackend`.

## Decisions Already Made

1. Framework: Avalonia with a C# .NET shared core library.
2. Shared core language: C#, rewritten from Swift.
3. Local-model-first strategy: Ollama-compatible endpoints as the primary local path.
4. Context providers (selected text, screen, browser) are optional capabilities in all platforms.
5. Windows MVP ships before macOS Avalonia shell.
6. The existing Swift macOS app remains in production until the macOS Avalonia shell reaches parity.

## Suggested First Technical Move

Do not write any Avalonia UI or platform adapter code yet.

Start by creating the solution and implementing `VoiceInk.Core` with:

1. `OllamaBackend` — HTTP calls to Ollama
2. `EnhancementPipeline` — takes backend, prompt, and optional context, returns rewritten text
3. `TranscriptionServiceRegistry` — routes by provider
4. Unit tests confirming the pipeline works with a mock backend

Once the core is proven in tests, the Avalonia shell and adapters can be built around it with much less rework risk.