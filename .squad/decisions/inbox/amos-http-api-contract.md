# Decision: VoiceInkService HTTP API Contract

**Author:** Amos  
**Date:** 2025-01-23  
**Status:** Proposed for team review

## Context

VoiceInk.Windows (Avalonia C# shell) needs to communicate with VoiceInkCore (Swift Package) via VoiceInkService (HTTP bridge). We need a stable REST API contract that both sides can implement and rely on.

## Decision

Defined the following REST API endpoints for VoiceInkService (port 7523):

### Health Check
```
GET /api/health
Response: 200 OK (empty body)
```

### Transcribe Audio
```
POST /api/transcribe
Content-Type: multipart/form-data
Fields:
  - audio: binary file (PCM/WAV format, 16kHz mono preferred)
  - model: string (model ID, e.g., "whisper-1")

Response: 200 OK
{
  "text": "transcribed text",
  "modelId": "whisper-1",
  "duration": "PT5.2S",
  "confidence": 0.95
}
```

### Enhance Text
```
POST /api/enhance
Content-Type: application/json
{
  "text": "raw text to enhance",
  "promptId": "fix-grammar",  // optional, use default if null
  "customPromptText": null,   // optional, override prompt
  "selectedText": null,       // optional, context
  "activeUrl": null           // optional, context
}

Response: 200 OK
{
  "enhancedText": "Enhanced and formatted text"
}
```

### List Models
```
GET /api/models
Response: 200 OK
[
  {
    "id": "whisper-1",
    "name": "Whisper",
    "provider": "OpenAI",
    "isLocal": false,
    "isAvailable": true
  },
  ...
]
```

## Rationale

- **Multipart for audio:** Binary data needs multipart/form-data encoding
- **JSON for enhancement:** Structured request with optional fields
- **Simple response models:** Easy to deserialize in C# with System.Text.Json
- **Standard HTTP status codes:** 200 OK for success, 400/500 for errors
- **Timeout tolerance:** Windows client uses 120s timeout for slow transcriptions

## Impact

- VoiceInkService implementation can reference this contract
- Windows C# client (VoiceInkHttpClient.cs) already implements this contract
- Any future clients (Linux, etc.) can use the same API

## Open Questions

- Should we use gRPC instead of REST for better performance?
- Should we add WebSocket support for streaming transcription?
- Should we version the API (e.g., /api/v1/transcribe)?
