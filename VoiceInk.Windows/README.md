# VoiceInk.Windows

Avalonia C# desktop app for Windows. Provides the Windows shell for VoiceInk.

## Architecture

This project is a thin UI shell. All business logic runs in VoiceInkService (the Swift HTTP bridge).

```
VoiceInk.Windows (this project) → HTTP :7523 → VoiceInkService → VoiceInkCore (Swift Package)
```

## Building

Requires Windows and .NET 9 SDK:

```powershell
dotnet build
dotnet run
```

## Adapters

Each adapter implements a Windows-native capability:

| Adapter | Windows API | Status |
|---------|-------------|--------|
| WasapiAudioCapture | WASAPI | 🚧 Stub |
| Win32GlobalShortcut | RegisterHotKey | 🚧 Stub |
| WindowsClipboardService | Avalonia Clipboard | ✅ |
| SendInputPasteService | SendInput | ✅ |
| WindowsToastNotification | WinRT Toast | 🚧 Stub |
| DpapiSecretStore | DPAPI | 🚧 Stub |

## VoiceInkService

Before running, VoiceInkService must be running on port 7523:

```bash
# From VoiceInkService/ directory (Swift executable):
swift run VoiceInkService
```
