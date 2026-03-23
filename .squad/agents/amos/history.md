# Amos — History

## Core Context

- **Project:** Cross-platform VoiceInk — extract a Swift Package core from the existing macOS app, wrap it in a local HTTP service, and build an Avalonia Windows shell that calls it, while preserving the existing macOS SwiftUI app.
- **Role:** Windows Dev
- **Joined:** 2026-03-23T00:37:36.339Z

## Learnings

### 2025-01-23: Windows Shell Adapter Implementation

**Architecture Pattern:**
- Path A (Swift Package Core): VoiceInk.Windows (Avalonia C#) → HTTP → VoiceInkService → VoiceInkCore (Swift Package)
- Windows shell is a thin client; all business logic stays in Swift core
- Communication via REST API on localhost:7523

**Key Files:**
- `VoiceInk.Windows/Interfaces/` - C# interfaces mirroring Swift protocols from VoiceInkCore
- `VoiceInk.Windows/Adapters/` - Platform-specific Windows implementations
- `VoiceInk.Windows/Services/VoiceInkHttpClient.cs` - REST client for VoiceInkService
- `VoiceInk.Windows/Services/CoreOrchestrator.cs` - Main pipeline coordinator

**Adapter Implementations:**
1. **WasapiAudioCapture** (IAudioCapture): WASAPI via NAudio for 16kHz mono PCM recording
2. **Win32GlobalShortcut** (IGlobalShortcut): RegisterHotKey P/Invoke with WM_HOTKEY message handling
3. **WindowsClipboardService** (IClipboardService): Avalonia cross-platform clipboard abstraction
4. **SendInputPasteService** (IPasteService): Win32 SendInput for Ctrl+V simulation with clipboard save/restore
5. **WindowsToastNotification** (INotificationService): Windows Toast (needs WinRT package)
6. **DpapiSecretStore** (ISecretStore): DPAPI encryption with LocalApplicationData file storage

**REST API Contract:**
- `POST /api/transcribe` - multipart/form-data (audio bytes + model ID)
- `POST /api/enhance` - JSON (EnhancementRequest)
- `GET /api/models` - JSON array of ModelInfo
- `GET /api/health` - health check

**Pipeline Flow:**
1. Hotkey press → Start WASAPI recording
2. Hotkey release → Stop recording
3. Send audio to VoiceInkService → transcribe
4. Send transcription to VoiceInkService → enhance
5. Paste result via SendInput (Ctrl+V)

**Patterns Used:**
- Interface-based DI for platform adapters
- P/Invoke for Win32 APIs (RegisterHotKey, SendInput)
- DPAPI for secure credential storage (ProtectedData.Protect/Unprotect)
- Avalonia cross-platform abstractions where available

**Blockers:**
- Cannot build on macOS (Windows-specific target framework)
- Need VoiceInkService implementation (Swift HTTP server)
- Win32GlobalShortcut needs Avalonia message pump for WM_HOTKEY
- WindowsToastNotification needs WinRT interop package

**PR:** https://github.com/jeanthink/VoiceInk/pull/10

<!-- Append learnings below -->
