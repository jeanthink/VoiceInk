# Cross-Platform Plan for VoiceInk

## Summary

Making VoiceInk work well on Windows is feasible, but it is not a small port.

The highest-value and most portable part of the product is the private local-model pipeline:

- local transcription
- local prompt rewriting
- user-owned LLM backends
- prompt-engineering workflows

The hardest part is the current macOS app shell, which is tightly coupled to macOS frameworks for:

- audio capture
- global hotkeys
- menu bar behavior
- window management
- clipboard paste and keyboard injection
- accessibility-based selected text capture
- browser context integration

The recommended approach is:

1. Rewrite the shared core logic into a C# .NET class library (`VoiceInk.Core`) with no platform dependencies.
2. Build Avalonia desktop shells for Windows, macOS, and Linux that wrap that core.
3. Implement per-platform adapters for audio, hotkeys, clipboard, tray, and notifications inside each shell project.
4. Keep the existing Swift macOS app running while the C# core is proven, then migrate.

The chosen cross-platform framework is **Avalonia** with a **C# .NET shared core class library**. This combination covers Windows, macOS, and Linux from a desktop-first baseline.

## Difficulty Assessment

### Shared Core Extraction

Difficulty: Medium to high

This is the work needed to separate app-independent logic from macOS-only logic.

Estimated effort:

- roughly 6 to 10 weeks for one developer

### Windows MVP

Difficulty: High

This would cover a functional Windows app with:

- recording
- transcription
- prompt rewriting
- clipboard insertion
- notifications
- basic hotkeys

Estimated effort:

- roughly 8 to 14 additional weeks after the shared core is stable

### Windows Feature Parity

Difficulty: High

This would include the more brittle system integrations, especially:

- selected text access
- browser URL or browser context integration
- full UX parity with the macOS app

Estimated effort:

- a later phase after MVP, not something to bundle into the first Windows release

## Product Direction

Your strongest product direction is not just cross-platform dictation.

It is a private voice workflow that turns spoken language into:

- production-ready prompts
- polished text
- structured rewrite outputs
- reusable prompt-engineering patterns

That direction is compatible with Windows support, and it maps well to a shared engine.

## Recommended Architecture

The architecture is three tiers: a shared C# core library, Avalonia shells per platform, and per-platform adapter implementations.

### Solution Structure

```
VoiceInk.Core/          C# .NET class library — no platform dependencies
VoiceInk.Windows/       Avalonia shell — Windows tray, WASAPI audio, Win32 hotkeys
VoiceInk.macOS/         Avalonia shell — macOS tray, CoreAudio adapter, Carbon hotkeys
VoiceInk.Linux/         Avalonia shell — Linux tray, PipeWire/ALSA adapter, X11/Wayland hotkeys
VoiceInk.Adapters/      Shared adapter interfaces — protocols/interfaces for platform services
```

### 1. VoiceInk.Core (C# class library)

This layer should own:

- transcription model selection
- transcription service routing
- local LLM backend routing
- prompt templates and prompt selection
- enhancement orchestration
- output filtering
- custom vocabulary injection
- local-only privacy behavior
- settings and model configuration models

This is where your rewrite logic should live. No Avalonia references. No platform APIs.

### 2. VoiceInk.Adapters (C# interface library)

Defines the contracts each platform shell must implement:

- `IAudioCapture` — start/stop recording, device enumeration, audio metering
- `IGlobalShortcut` — register/unregister hotkeys, push-to-talk, toggle modes
- `IClipboardService` — read and write text to the clipboard
- `IPasteService` — simulate text insertion into another app
- `INotificationService` — display system notifications
- `ISecretStore` — secure credential storage
- `IContextProvider` — optional selected text, screen capture, browser URL

### 3. Avalonia Platform Shells

Each shell project owns:

- Avalonia window and tray lifecycle
- concrete implementations of every adapter interface
- platform permission and onboarding flows
- OS-specific UX conventions

This keeps the platform-specific risk out of the core product logic.

## Why This Is Hard

The current codebase is written in Swift and is deeply integrated with macOS frameworks. Moving to a C#/.NET shared core is not a line-by-line port — it is a deliberate rewrite of the business logic layer into a new language and runtime.

The macOS-specific parts that need replacement:

- [VoiceInk/CoreAudioRecorder.swift](VoiceInk/CoreAudioRecorder.swift) — Core Audio; replaced by `IAudioCapture` adapter per platform
- [VoiceInk/HotkeyManager.swift](VoiceInk/HotkeyManager.swift) — Carbon/AppKit; replaced by `IGlobalShortcut` adapter per platform
- [VoiceInk/MenuBarManager.swift](VoiceInk/MenuBarManager.swift) — menu bar; replaced by Avalonia tray integration
- [VoiceInk/WindowManager.swift](VoiceInk/WindowManager.swift) — AppKit windows; replaced by Avalonia window management
- [VoiceInk/PowerMode/BrowserURLService.swift](VoiceInk/PowerMode/BrowserURLService.swift) — AppleScript; becomes an optional `IContextProvider` with per-platform or per-browser implementations

The rewrite cost is real, but the gain is a shared engine that runs natively on Windows, macOS, and Linux without any further porting work.

## Why Your Local LLM Idea Is Strong

The local-model and rewrite logic is almost entirely HTTP and data logic — it has no hard platform dependency.

The current Swift codebase already proves the concept:

- [VoiceInk/Models/TranscriptionModel.swift](VoiceInk/Models/TranscriptionModel.swift) — the provider/model abstraction maps cleanly to a C# interface
- [VoiceInk/Services/TranscriptionServiceRegistry.swift](VoiceInk/Services/TranscriptionServiceRegistry.swift) — the routing pattern maps to a C# service registry in `VoiceInk.Core`
- [VoiceInk/Services/AIEnhancement/AIEnhancementService.swift](VoiceInk/Services/AIEnhancement/AIEnhancementService.swift) — the rewrite orchestration maps to a C# `EnhancementPipeline` in `VoiceInk.Core`
- [VoiceInk/Services/OllamaService.swift](VoiceInk/Services/OllamaService.swift) — Ollama is HTTP-based and translates directly to a C# `OllamaBackend` in `VoiceInk.Core`

All of that logic can be rewritten in C# and shared across Windows, macOS, and Linux Avalonia shells with no further porting needed.

## Phased Plan

## Phase 1: Set Up the .NET Solution

Create the C# solution with project references in place:

```
VoiceInk.sln
  VoiceInk.Core          (class library — net9.0)
  VoiceInk.Adapters      (class library — net9.0, interface definitions only)
  VoiceInk.Windows       (Avalonia app — net9.0-windows)
  VoiceInk.macOS         (Avalonia app — net9.0-macos)
  VoiceInk.Linux         (Avalonia app — net9.0)
```

Each shell references `VoiceInk.Core` and `VoiceInk.Adapters`. No shell references another shell.

## Phase 2: Implement VoiceInk.Adapters

Define the platform service interfaces:

- `IAudioCapture` — start/stop recording, device list, audio meter events
- `IGlobalShortcut` — register hotkey, push-to-talk, toggle, hybrid modes
- `IClipboardService` — read/write text
- `IPasteService` — simulate text insertion at the cursor
- `INotificationService` — show toast or tray balloon notifications
- `ISecretStore` — store and retrieve API keys and secrets
- `IContextProvider` — optional: selected text, screen text, active browser URL

None of these interfaces import platform libraries.

## Phase 3: Implement VoiceInk.Core

Rewrite the shared product logic into C#:

- `TranscriptionModel` and `ITranscriptionBackend` — maps from current Swift `TranscriptionModel` protocol
- `TranscriptionServiceRegistry` — maps from current Swift `TranscriptionServiceRegistry`
- `OllamaBackend : ILocalLLMBackend` — maps from current Swift `OllamaService`
- `EnhancementPipeline` — maps from current Swift `AIEnhancementService`
- `PromptTemplate` and `CustomPrompt` — maps from current Swift `CustomPrompt` and `PromptTemplates`
- `EnhancementOutputFilter` — maps from current Swift `AIEnhancementOutputFilter`
- `VocabularyInjector` — maps from current Swift custom vocabulary logic
- `SettingsStore` — platform-agnostic settings using `ISecretStore`

All Ollama and OpenAI-compatible HTTP calls live here. No Avalonia imports. No platform SDK imports.

## Phase 4: Build the Windows Shell

Create `VoiceInk.Windows` as an Avalonia desktop app.

Implement the adapter interfaces using Windows APIs:

- `IAudioCapture` → WASAPI via NAudio or Windows.Media.Capture
- `IGlobalShortcut` → `RegisterHotKey` Win32 API
- `IClipboardService` → `System.Windows.Clipboard` or Win32 clipboard
- `IPasteService` → `SendInput` Win32 API
- `INotificationService` → Windows Toast notifications
- `ISecretStore` → Windows Credential Manager (DPAPI)

The Avalonia shell provides:

- system tray icon and context menu
- compact floating recorder window
- settings panel
- history view
- onboarding and permissions flow

## Phase 5: Build the macOS Shell

Create `VoiceInk.macOS` as an Avalonia desktop app.

Implement the adapter interfaces using macOS APIs:

- `IAudioCapture` → CoreAudio or AVFoundation via P/Invoke or native interop
- `IGlobalShortcut` → Carbon or CGEvent via P/Invoke
- `IClipboardService` → NSPasteboard via interop
- `IPasteService` → CGEvent keyboard simulation via interop
- `INotificationService` → macOS UserNotifications framework
- `ISecretStore` → Keychain via interop

The Avalonia shell provides the same panels and flows as the Windows shell, adapted to macOS UX conventions.

The existing Swift macOS app continues running during this phase as the production version.

## Phase 6: Build the Linux Shell

Create `VoiceInk.Linux` as an Avalonia desktop app.

Implement the adapter interfaces using Linux APIs:

- `IAudioCapture` → PipeWire or ALSA
- `IGlobalShortcut` → X11/XGrabKey or libinput on Wayland
- `IClipboardService` → X11 clipboard or Wayland data device
- `IPasteService` → XSendEvent or ydotool on Wayland
- `INotificationService` → freedesktop D-Bus notifications
- `ISecretStore` → libsecret or KWallet

## Phase 7: Add Optional Context Providers

Add `IContextProvider` implementations after the MVP shell is stable:

- selected text via UI Automation (Windows), Accessibility API (macOS), AT-SPI (Linux)
- screen capture context via DXGI (Windows), ScreenCaptureKit interop (macOS), PipeWire screenshare (Linux)
- browser URL via Chrome DevTools Protocol or browser extensions (all platforms)

These are additive and should not block the first release on any platform.

## Recommended Milestone Order

If timeline matters, the safest release sequence is:

1. `VoiceInk.Core` and `VoiceInk.Adapters` working with all logic tested
2. Windows MVP Avalonia shell with local transcription and local rewrite
3. macOS Avalonia shell replacing the existing Swift app
4. Linux shell
5. Advanced context providers

## Swift Reference Files

These are the existing Swift files whose behavior must be faithfully reproduced in the C# rewrite.

| Swift file | C# target | Project |
|---|---|---|
| [VoiceInk/Models/TranscriptionModel.swift](VoiceInk/Models/TranscriptionModel.swift) | `ITranscriptionModel` | `VoiceInk.Adapters` |
| [VoiceInk/Services/TranscriptionServiceRegistry.swift](VoiceInk/Services/TranscriptionServiceRegistry.swift) | `TranscriptionServiceRegistry` | `VoiceInk.Core` |
| [VoiceInk/Services/AIEnhancement/AIEnhancementService.swift](VoiceInk/Services/AIEnhancement/AIEnhancementService.swift) | `EnhancementPipeline` | `VoiceInk.Core` |
| [VoiceInk/Services/AIEnhancement/AIService.swift](VoiceInk/Services/AIEnhancement/AIService.swift) | `ILocalLLMBackend`, `OpenAICompatibleBackend` | `VoiceInk.Core` |
| [VoiceInk/Services/OllamaService.swift](VoiceInk/Services/OllamaService.swift) | `OllamaBackend` | `VoiceInk.Core` |
| [VoiceInk/Models/CustomPrompt.swift](VoiceInk/Models/CustomPrompt.swift) | `CustomPrompt` record | `VoiceInk.Core` |
| [VoiceInk/Models/PromptTemplates.swift](VoiceInk/Models/PromptTemplates.swift) | `PromptTemplate` factory | `VoiceInk.Core` |
| [VoiceInk/Recorder.swift](VoiceInk/Recorder.swift) + [VoiceInk/CoreAudioRecorder.swift](VoiceInk/CoreAudioRecorder.swift) | `IAudioCapture` | `VoiceInk.Adapters` |
| [VoiceInk/HotkeyManager.swift](VoiceInk/HotkeyManager.swift) | `IGlobalShortcut` | `VoiceInk.Adapters` |
| [VoiceInk/ClipboardManager.swift](VoiceInk/ClipboardManager.swift) | `IClipboardService` | `VoiceInk.Adapters` |
| [VoiceInk/CursorPaster.swift](VoiceInk/CursorPaster.swift) | `IPasteService` | `VoiceInk.Adapters` |
| [VoiceInk/Notifications/NotificationManager.swift](VoiceInk/Notifications/NotificationManager.swift) | `INotificationService` | `VoiceInk.Adapters` |
| [VoiceInk/Services/KeychainService.swift](VoiceInk/Services/KeychainService.swift) | `ISecretStore` | `VoiceInk.Adapters` |
| [VoiceInk/Services/SelectedTextService.swift](VoiceInk/Services/SelectedTextService.swift) | `IContextProvider` | `VoiceInk.Adapters` |
| [VoiceInk/PowerMode/BrowserURLService.swift](VoiceInk/PowerMode/BrowserURLService.swift) | `IContextProvider` | `VoiceInk.Adapters` |
| [VoiceInk/MenuBarManager.swift](VoiceInk/MenuBarManager.swift) | Avalonia tray + context menu | `VoiceInk.macOS` |
| [VoiceInk/WindowManager.swift](VoiceInk/WindowManager.swift) | Avalonia window lifecycle | each shell |
| [VoiceInk/Services/ScreenCaptureService.swift](VoiceInk/Services/ScreenCaptureService.swift) | `IContextProvider` (screen) | `VoiceInk.Adapters` |

## Verification Checklist

1. Confirm `VoiceInk.Core` builds as a standalone library with no Avalonia, platform SDK, or UI references.
2. Verify prompt rewriting works end-to-end in `VoiceInk.Core` unit tests using a mock `ILocalLLMBackend`.
3. Verify transcription service routing works in `VoiceInk.Core` with both local and cloud model stubs.
4. Verify each Avalonia shell builds and launches on its target OS.
5. On Windows: validate record, transcribe, rewrite, paste, and notify before any advanced integrations.
6. On macOS: confirm parity with the existing Swift app before retiring it.
7. Verify local-only mode never makes unintended cloud calls on any platform.

## Bottom Line

This is a substantial implementation project, not a small compatibility tweak.

But the part you care most about, private local models plus rewrite and prompt-engineering workflows, is the part that is most worth extracting and the part that is most realistic to make cross-platform.

If you execute it in the right order, you can build:

- a shared C# .NET core library (`VoiceInk.Core`) with all product logic
- Avalonia shells for Windows, macOS, and Linux that wrap that core
- one consistent local-LLM and prompt-rewrite experience across all three platforms

The correct first implementation move is to create the C# solution and write `VoiceInk.Core`, not to start writing Windows APIs inside the existing Swift macOS structure.