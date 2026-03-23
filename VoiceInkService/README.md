# VoiceInkService

HTTP bridge service that wraps VoiceInkCore and exposes it as a local REST API.

## Purpose

VoiceInk.Windows (Avalonia C#) cannot import Swift packages directly. VoiceInkService runs as a sidecar process alongside the Windows app and provides all intelligence via HTTP on `127.0.0.1:7523`.

## Architecture

```
VoiceInk.Windows (C# Avalonia)
    ↓ HTTP :7523
VoiceInkService (Swift executable)
    ↓ Swift import
VoiceInkCore (Swift Package)
```

## API

| Method | Path | Description |
|--------|------|-------------|
| GET | /health | Health check |
| GET | /models | List available transcription models |
| POST | /transcribe | Transcribe audio (multipart/form-data) |
| POST | /enhance | Enhance text with AI |
| GET | /prompts | List all prompts |
| POST | /prompts | Create custom prompt |
| DELETE | /prompts/:id | Delete prompt |
| GET | /settings | Get app settings |
| PATCH | /settings | Update settings |

### POST /transcribe

Request: `multipart/form-data`
- `audio`: binary audio data (WAV/PCM)
- `modelId`: string

Response:
```json
{ "text": "...", "duration": 2.3, "confidence": 0.95, "modelId": "whisper-tiny" }
```

### POST /enhance

Request:
```json
{
  "text": "...",
  "promptId": "email",
  "customPrompt": null,
  "context": { "selectedText": "...", "activeUrl": "..." }
}
```

Response:
```json
{ "enhancedText": "...", "model": "gpt-4o" }
```

## Running

```bash
# With real VoiceInkCore (after Naomi's PR is merged):
swift run VoiceInkService --port 7523

# With stub bridge (for development/testing without VoiceInkCore):
swift run VoiceInkService --stub --port 7523

# Custom host/port:
swift run VoiceInkService --host 127.0.0.1 --port 8080
```

## Process Lifecycle

VoiceInkService is started by VoiceInk.Windows on launch and killed on quit.
It binds to `127.0.0.1` only — never accessible from outside the machine.
Handles `SIGINT` and `SIGTERM` for clean shutdown.

## HTTP Implementation

The HTTP transport is currently scaffolded. Production implementation will use swift-nio or a similar library.

To wire up swift-nio:
1. Uncomment the `swift-nio` dependency in `Package.swift`
2. Implement `HTTPServer.start()` using `ServerBootstrap`

## VoiceInkCore Dependency

VoiceInkCore is being developed separately (Naomi's `feature/voiceinkcore-package` branch).

- `CoreBridgeProtocol` — abstract interface; keeps VoiceInkService compilable without VoiceInkCore
- `StubCoreBridge` — full working stub for dev and testing
- `VoiceInkCoreBridge` — real implementation; wire up once Naomi's PR merges by uncommenting `import VoiceInkCore` and the package dependency in `Package.swift`
