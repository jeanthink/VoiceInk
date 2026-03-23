# VoiceInk Cross-Platform Implementation Backlog

## Purpose

This backlog turns the cross-platform plan into concrete implementation work.

The chosen architecture is:

- **`VoiceInk.Core`** — C# .NET class library, no platform dependencies, owns all product logic
- **`VoiceInk.Adapters`** — C# interface library defining platform service contracts
- **`VoiceInk.Windows`** — Avalonia desktop shell for Windows
- **`VoiceInk.macOS`** — Avalonia desktop shell for macOS
- **`VoiceInk.Linux`** — Avalonia desktop shell for Linux

The backlog is organized in the order that reduces architectural risk:

1. create the .NET solution and project structure
2. define adapter interfaces
3. implement the shared C# core
4. implement the Windows Avalonia shell
5. implement the macOS Avalonia shell
6. implement the Linux Avalonia shell
7. add advanced optional context providers

## Priority Legend

- P0: blocks the architecture
- P1: required for Windows MVP
- P2: important, but can follow MVP
- P3: polish or later parity work

## Milestone 0: Solution Setup

### P0. Create the .NET solution and project scaffolding

Tasks:

- create `VoiceInk.sln` at the repo root
- create `VoiceInk.Core` as a `net9.0` class library
- create `VoiceInk.Adapters` as a `net9.0` class library
- create `VoiceInk.Windows` as an Avalonia `net9.0-windows` app
- create `VoiceInk.macOS` as an Avalonia `net9.0-macos` app
- create `VoiceInk.Linux` as an Avalonia `net9.0` app
- set project references: each shell depends on `VoiceInk.Core` and `VoiceInk.Adapters`
- add Avalonia NuGet packages to each shell project

Acceptance criteria:

- solution builds on all three platforms with empty projects
- `VoiceInk.Core` has zero platform-specific references

### P0. Define the adapter interface set in VoiceInk.Adapters

Tasks:

- `IAudioCapture` — start/stop, device enumeration, audio meter events
- `IGlobalShortcut` — register/unregister, push-to-talk, toggle, hybrid modes
- `IClipboardService` — read and write text
- `IPasteService` — simulate keyboard text insertion
- `INotificationService` — display system notifications
- `ISecretStore` — save and retrieve credentials
- `IContextProvider` — optional: selected text, screen text, active browser URL

Swift originals to use as reference:

- [VoiceInk/Recorder.swift](VoiceInk/Recorder.swift) → `IAudioCapture`
- [VoiceInk/HotkeyManager.swift](VoiceInk/HotkeyManager.swift) → `IGlobalShortcut`
- [VoiceInk/ClipboardManager.swift](VoiceInk/ClipboardManager.swift) → `IClipboardService`
- [VoiceInk/CursorPaster.swift](VoiceInk/CursorPaster.swift) → `IPasteService`
- [VoiceInk/Notifications/NotificationManager.swift](VoiceInk/Notifications/NotificationManager.swift) → `INotificationService`
- [VoiceInk/Services/KeychainService.swift](VoiceInk/Services/KeychainService.swift) → `ISecretStore`
- [VoiceInk/Services/SelectedTextService.swift](VoiceInk/Services/SelectedTextService.swift) → `IContextProvider`

Acceptance criteria:

- every interface is defined with no implementation
- no platform-specific types appear in any interface signature

## Milestone 1: VoiceInk.Core Implementation

### P0. Implement transcription model and provider registry

Swift reference:

- [VoiceInk/Models/TranscriptionModel.swift](VoiceInk/Models/TranscriptionModel.swift)
- [VoiceInk/Services/TranscriptionServiceRegistry.swift](VoiceInk/Services/TranscriptionServiceRegistry.swift)

C# deliverables:

- `ITranscriptionModel` interface
- `ModelProvider` enum matching current Swift cases: local, cloud, parakeet, nativeApple
- `TranscriptionServiceRegistry` class that routes to correct backend by provider
- `LocalTranscriptionBackend` stub calling whisper.cpp via P/Invoke or HTTP
- `CloudTranscriptionBackend` using `HttpClient` for OpenAI-compatible APIs

Acceptance criteria:

- registry routes to correct backend by provider enum
- `VoiceInk.Core` has no Avalonia or platform imports

### P0. Implement AI enhancement pipeline and local LLM backends

Swift reference:

- [VoiceInk/Services/AIEnhancement/AIEnhancementService.swift](VoiceInk/Services/AIEnhancement/AIEnhancementService.swift)
- [VoiceInk/Services/AIEnhancement/AIService.swift](VoiceInk/Services/AIEnhancement/AIService.swift)
- [VoiceInk/Services/OllamaService.swift](VoiceInk/Services/OllamaService.swift)

C# deliverables:

- `ILocalLLMBackend` interface with `EnhanceAsync(text, systemPrompt, model)` method
- `OllamaBackend : ILocalLLMBackend` using `HttpClient` to call Ollama HTTP API
- `OpenAICompatibleBackend : ILocalLLMBackend` for self-hosted endpoints
- `EnhancementPipeline` class accepting `ILocalLLMBackend` and `IContextProvider?`
- `EnhancementOutputFilter` removing reasoning tags from output

Acceptance criteria:

- adding a new backend requires only a new class implementing `ILocalLLMBackend`
- pipeline runs without any context providers and degrades gracefully

### P0. Implement prompt system

Swift reference:

- [VoiceInk/Models/CustomPrompt.swift](VoiceInk/Models/CustomPrompt.swift)
- [VoiceInk/Models/PromptTemplates.swift](VoiceInk/Models/PromptTemplates.swift)
- [VoiceInk/Models/AIPrompts.swift](VoiceInk/Models/AIPrompts.swift)

C# deliverables:

- `CustomPrompt` record with id, title, promptText, icon, triggerWords, useSystemInstructions
- `PromptTemplate` enum or factory matching current Swift templates
- `PromptRegistry` service for loading, saving, and selecting prompts
- JSON serialization for user-defined prompts

Acceptance criteria:

- prompts round-trip correctly through JSON
- predefined prompts are available without user configuration

### P1. Implement settings and secrets storage

Swift reference:

- [VoiceInk/Services/UserDefaultsManager.swift](VoiceInk/Services/UserDefaultsManager.swift)
- [VoiceInk/Services/APIKeyManager.swift](VoiceInk/Services/APIKeyManager.swift)
- [VoiceInk/Services/KeychainService.swift](VoiceInk/Services/KeychainService.swift)

C# deliverables:

- `AppSettings` class serialized to JSON in a platform-agnostic location
- `ISecretStore` usage for all API key read/write operations
- no direct platform storage calls inside `VoiceInk.Core`

Acceptance criteria:

- settings load and save without any platform-specific code in Core

## Milestone 2: macOS Stabilization on Shared Interfaces

### P0. Rewire current recorder stack behind an audio capture interface

Targets:

- [VoiceInk/Recorder.swift](VoiceInk/Recorder.swift)
- [VoiceInk/CoreAudioRecorder.swift](VoiceInk/CoreAudioRecorder.swift)
- [VoiceInk/Services/AudioDeviceManager.swift](VoiceInk/Services/AudioDeviceManager.swift)

Tasks:

- keep existing recording behavior while hiding Core Audio implementation details behind an interface
- preserve streaming chunks, device switching, metering, and failure handling

Acceptance criteria:

- existing macOS recording flow still works unchanged from the user’s perspective

### P0. Rewire macOS hotkey handling behind an input shortcut interface

Targets:

- [VoiceInk/HotkeyManager.swift](VoiceInk/HotkeyManager.swift)
- [VoiceInk/MiniRecorderShortcutManager.swift](VoiceInk/MiniRecorderShortcutManager.swift)
- [VoiceInk/PowerMode/PowerModeShortcutManager.swift](VoiceInk/PowerMode/PowerModeShortcutManager.swift)

Tasks:

- move shortcut registration and event monitoring behind a platform-specific adapter
- preserve current behavior for toggle, push-to-talk, and hybrid modes

Acceptance criteria:

- current macOS hotkeys behave the same after the refactor

### P1. Rewire notifications, clipboard, and paste behavior

Targets:

- [VoiceInk/ClipboardManager.swift](VoiceInk/ClipboardManager.swift)
- [VoiceInk/CursorPaster.swift](VoiceInk/CursorPaster.swift)
- [VoiceInk/Notifications/NotificationManager.swift](VoiceInk/Notifications/NotificationManager.swift)

Tasks:

- isolate clipboard read/write and paste simulation behind explicit interfaces
- isolate app notifications behind a platform service

Acceptance criteria:

- macOS clipboard restoration and paste behavior still works
- notification calls do not directly leak platform-specific APIs into shared flows

## Milestone 3: macOS Avalonia Shell

### P0. Implement macOS platform adapters

Swift reference behavior to match:

- [VoiceInk/Recorder.swift](VoiceInk/Recorder.swift) + [VoiceInk/CoreAudioRecorder.swift](VoiceInk/CoreAudioRecorder.swift) → `CoreAudioCapture : IAudioCapture` via P/Invoke
- [VoiceInk/HotkeyManager.swift](VoiceInk/HotkeyManager.swift) → `MacOSGlobalShortcut : IGlobalShortcut` via CGEvent P/Invoke
- [VoiceInk/ClipboardManager.swift](VoiceInk/ClipboardManager.swift) → `NSPasteboardClipboard : IClipboardService`
- [VoiceInk/CursorPaster.swift](VoiceInk/CursorPaster.swift) → `CGEventPasteService : IPasteService`
- [VoiceInk/Notifications/NotificationManager.swift](VoiceInk/Notifications/NotificationManager.swift) → `MacOSNotificationService : INotificationService`
- [VoiceInk/Services/KeychainService.swift](VoiceInk/Services/KeychainService.swift) → `KeychainSecretStore : ISecretStore`

Acceptance criteria:

- all adapters implement their interfaces
- behavior matches the existing Swift app behavior for each capability

### P0. Implement macOS Avalonia shell UI

Deliverables:

- macOS menu bar extra or tray icon replacing [VoiceInk/MenuBarManager.swift](VoiceInk/MenuBarManager.swift)
- compact recorder panel
- settings and history windows
- macOS-specific onboarding for microphone and accessibility permissions

Acceptance criteria:

- macOS shell is functionally equivalent to the existing Swift app on the MVP feature set
- existing Swift app can be retired after parity is confirmed

## Milestone 4: Linux Avalonia Shell

### P1. Implement Linux platform adapters

Deliverables:

- `PipeWireAudioCapture : IAudioCapture` or ALSA fallback
- `X11GlobalShortcut : IGlobalShortcut` or libinput on Wayland
- `X11ClipboardService : IClipboardService`
- `XdoToolPasteService : IPasteService` or ydotool on Wayland
- `FreedesktopNotificationService : INotificationService` via D-Bus
- `LibsecretStore : ISecretStore` or KWallet fallback

Acceptance criteria:

- all adapters implement their interfaces on a standard Linux desktop

### P1. Implement Linux Avalonia shell UI

Deliverables:

- tray icon via Avalonia or system notification area fallback
- compact recorder panel
- settings and history windows
- Linux-specific onboarding for microphone permission

Acceptance criteria:

- the record → transcribe → rewrite → paste flow works on Ubuntu and Fedora

## Milestone 5: Advanced Context Capabilities

### P2. Selected text support

Swift reference:

- [VoiceInk/Services/SelectedTextService.swift](VoiceInk/Services/SelectedTextService.swift)

C# deliverables:

- `IContextProvider` implementation per platform
- Windows: UI Automation via `System.Windows.Automation`
- macOS: Accessibility API via P/Invoke
- Linux: AT-SPI via D-Bus

Acceptance criteria:

- selected text is injected as context when available
- missing selected text does not break the rewrite pipeline

### P2. Screen capture context

Swift reference:

- [VoiceInk/Services/ScreenCaptureService.swift](VoiceInk/Services/ScreenCaptureService.swift)

C# deliverables:

- Windows: DXGI capture + OCR via Windows.Media.Ocr
- macOS: ScreenCaptureKit interop + Vision OCR
- Linux: PipeWire screenshare + Tesseract

Acceptance criteria:

- screen context is injected when permitted
- missing screen capture does not block the rewrite pipeline

### P3. Browser URL and browser context integration

Swift reference:

- [VoiceInk/PowerMode/BrowserURLService.swift](VoiceInk/PowerMode/BrowserURLService.swift)

C# deliverables:

- Chrome DevTools Protocol (CDP) client for Chrome-based browsers
- browser extension messaging for Firefox
- graceful degradation when browser is not supported

Acceptance criteria:

- unsupported browsers fail safely without crashing the adapter
- the rest of the app works without browser integration

## C# Implementation Order

This is the practical order to build each piece.

1. Create `.NET` solution and project structure
2. Define all `VoiceInk.Adapters` interfaces (no implementation yet)
3. Implement `VoiceInk.Core` — transcription registry and models
4. Implement `VoiceInk.Core` — Ollama backend and OpenAI-compatible backend
5. Implement `VoiceInk.Core` — enhancement pipeline and output filter
6. Implement `VoiceInk.Core` — prompt system and vocabulary injector
7. Implement `VoiceInk.Core` — settings store using `ISecretStore`
8. Implement all Windows adapters in `VoiceInk.Windows`
9. Implement Avalonia tray and window UI in `VoiceInk.Windows`
10. Implement all macOS adapters in `VoiceInk.macOS`
11. Implement Avalonia tray and window UI in `VoiceInk.macOS`
12. Implement all Linux adapters in `VoiceInk.Linux`
13. Add optional context providers per platform

## Swift Reference Mapping

When implementing C# equivalents, use these Swift files as the behavior reference.

| Swift file | C# target | Project |
|---|---|---|
| `TranscriptionModel.swift` | `ITranscriptionModel` | `VoiceInk.Adapters` |
| `TranscriptionServiceRegistry.swift` | `TranscriptionServiceRegistry` | `VoiceInk.Core` |
| `AIEnhancementService.swift` | `EnhancementPipeline` | `VoiceInk.Core` |
| `AIService.swift` | `ILocalLLMBackend`, `OpenAICompatibleBackend` | `VoiceInk.Core` |
| `OllamaService.swift` | `OllamaBackend` | `VoiceInk.Core` |
| `CustomPrompt.swift` | `CustomPrompt` record | `VoiceInk.Core` |
| `PromptTemplates.swift` | `PromptTemplate` factory | `VoiceInk.Core` |
| `AIEnhancementOutputFilter.swift` | `EnhancementOutputFilter` | `VoiceInk.Core` |
| `Recorder.swift` + `CoreAudioRecorder.swift` | `IAudioCapture` | `VoiceInk.Adapters` |
| `HotkeyManager.swift` | `IGlobalShortcut` | `VoiceInk.Adapters` |
| `ClipboardManager.swift` | `IClipboardService` | `VoiceInk.Adapters` |
| `CursorPaster.swift` | `IPasteService` | `VoiceInk.Adapters` |
| `NotificationManager.swift` | `INotificationService` | `VoiceInk.Adapters` |
| `KeychainService.swift` | `ISecretStore` | `VoiceInk.Adapters` |
| `SelectedTextService.swift` | `IContextProvider` | `VoiceInk.Adapters` |
| `BrowserURLService.swift` | `IContextProvider` | `VoiceInk.Adapters` |

## Immediate First Tasks

1. Create `VoiceInk.sln` and all five projects
2. Write the `VoiceInk.Adapters` interface files
3. Write `OllamaBackend` and `OpenAICompatibleBackend` in `VoiceInk.Core`
4. Write `EnhancementPipeline` wiring the backend and prompt system together
5. Verify `VoiceInk.Core` builds with zero platform references