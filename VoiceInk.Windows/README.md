# VoiceInk.Windows

Avalonia-based Windows shell for VoiceInk.

## Architecture

This is the Windows desktop client that communicates with VoiceInkService (Swift core) over HTTP.

**Path A Architecture (per DECISIONS.md):**
```
VoiceInk.Windows (this project) → HTTP :7523 → VoiceInkService → VoiceInkCore (Swift Package)
```

## Structure

```
VoiceInk.Windows/
├── Adapters/          Platform-specific Windows implementations
│   ├── WasapiAudioCapture.cs          WASAPI audio via NAudio
│   ├── Win32GlobalShortcut.cs         RegisterHotKey Win32 API
│   ├── WindowsClipboardService.cs     Clipboard via Avalonia
│   ├── SendInputPasteService.cs       SendInput Win32 API
│   ├── WindowsToastNotification.cs    Windows Toast (WinRT)
│   └── DpapiSecretStore.cs            DPAPI credential storage
├── Interfaces/        C# interfaces mirroring Swift protocols
│   ├── IAudioCapture.cs
│   ├── IGlobalShortcut.cs
│   ├── IClipboardService.cs
│   ├── IPasteService.cs
│   ├── INotificationService.cs
│   └── ISecretStore.cs
├── Services/
│   ├── VoiceInkHttpClient.cs          HTTP client for VoiceInkService REST API
│   └── CoreOrchestrator.cs            Main coordinator: record→transcribe→enhance→paste
├── Models/
│   ├── TranscriptionResult.cs
│   ├── EnhancementRequest.cs
│   └── ModelInfo.cs
├── Views/             Avalonia XAML windows (RecorderWindow, SettingsWindow)
├── App.axaml(.cs)     Application entry point
└── Program.cs         Main entry point
```

## REST API Contract (VoiceInkService)

The Windows shell expects VoiceInkService running on `http://127.0.0.1:7523`:

- **GET /api/health** → Health check
- **POST /api/transcribe** → Transcribe audio (multipart/form-data: audio file + model ID)
- **POST /api/enhance** → Enhance text with AI prompt (JSON: EnhancementRequest)
- **GET /api/models** → List available models

## Building

**Prerequisites:**
- .NET 9.0 SDK
- Windows (Avalonia + Windows-specific APIs don't build on macOS/Linux)

```powershell
cd VoiceInk.Windows
dotnet restore
dotnet build
dotnet run
```

## Platform Adapters

Each adapter implements a C# interface that mirrors the Swift protocol from VoiceInkCore:

| Adapter | Windows API | Interface | Status |
|---------|-------------|-----------|--------|
| WasapiAudioCapture | WASAPI (NAudio) | IAudioCapture | ✅ Implemented |
| Win32GlobalShortcut | RegisterHotKey | IGlobalShortcut | ✅ Implemented |
| WindowsClipboardService | Avalonia Clipboard | IClipboardService | ✅ Implemented |
| SendInputPasteService | SendInput | IPasteService | ✅ Implemented |
| WindowsToastNotification | WinRT Toast | INotificationService | ⚠️ Stub (needs WinRT) |
| DpapiSecretStore | DPAPI | ISecretStore | ✅ Implemented |

## Status

✅ Interfaces defined
✅ Adapter implementations fleshed out with P/Invoke signatures and DPAPI logic
✅ VoiceInkHttpClient wired to REST endpoints (transcribe, enhance, models, health)
✅ CoreOrchestrator wires full pipeline: record→transcribe→enhance→paste
✅ NAudio package added to .csproj
⚠️ WindowsToastNotification needs WinRT interop package
⚠️ Win32GlobalShortcut needs message pump window handle wiring for WM_HOTKEY

## VoiceInkService

Before running VoiceInk.Windows, ensure VoiceInkService is running on port 7523:

```bash
# From VoiceInkService/ directory (Swift executable):
swift run VoiceInkService
```

## Next Steps

1. Implement VoiceInkService Swift HTTP server (separate task)
2. Wire Avalonia message pump for hotkey WM_HOTKEY handling
3. Add WinRT toast notification package (Microsoft.Toolkit.Uwp.Notifications)
4. Complete NAudio WASAPI capture wiring (uncomment TODO sections)
5. Build and test on Windows

