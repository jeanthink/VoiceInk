# VoiceInkService

VoiceInkService is a lightweight HTTP bridge that wraps VoiceInkCore and exposes a local REST API for non-Swift platform shells (Windows, Linux).

## Architecture

Following **Path A** from DECISIONS.md:
- VoiceInkCore contains all shared business logic as a Swift Package
- VoiceInkService is a thin HTTP wrapper around VoiceInkCore
- Non-Swift shells (Windows Avalonia) communicate with VoiceInkCore via this HTTP API
- macOS SwiftUI app imports VoiceInkCore directly (no HTTP needed)

## Running the Service

```bash
cd VoiceInkService
swift run VoiceInkService
```

The service starts on `http://127.0.0.1:8787` by default.

To use a different port:
```bash
PORT=9090 swift run VoiceInkService
```

## API Endpoints

### Health Check

**GET** `/api/health`

Returns service health status.

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2024-03-23T12:00:00Z"
}
```

---

### Transcription

**POST** `/api/transcribe`

Transcribes audio data to text.

**Request:**
- Body: Raw audio bytes (WAV, MP3, M4A, etc.) or multipart form data
- Query params (optional):
  - `language`: Target language code (e.g., "en", "es")
  - `model`: Transcription model to use (default: "whisper-default")

**Example (multipart form):**
```json
{
  "audioData": "<base64-encoded-audio>",
  "language": "en",
  "model": "whisper-base"
}
```

**Response:**
```json
{
  "text": "Transcribed text here",
  "language": "en",
  "duration": 1.234,
  "model": "whisper-base"
}
```

---

**GET** `/api/models`

Lists available transcription models.

**Response:**
```json
{
  "models": [
    {
      "id": "whisper-base",
      "name": "Whisper Base",
      "type": "local",
      "provider": "OpenAI",
      "available": true
    }
  ]
}
```

---

### Enhancement

**POST** `/api/enhance`

Enhances text using AI models.

**Request:**
```json
{
  "text": "text to enhance",
  "promptId": "grammar-fix",
  "systemPrompt": "Optional custom system prompt",
  "model": "llama3",
  "temperature": 0.7,
  "maxTokens": 2000
}
```

**Response:**
```json
{
  "originalText": "text to enhance",
  "enhancedText": "Enhanced text here",
  "model": "llama3",
  "promptUsed": "grammar-fix",
  "tokensUsed": 150
}
```

---

**GET** `/api/prompts`

Lists available enhancement prompts.

**Response:**
```json
{
  "prompts": [
    {
      "id": "grammar-fix",
      "name": "Grammar Fix",
      "description": "Fix grammar and punctuation",
      "systemPrompt": "You are a helpful assistant...",
      "category": "correction"
    }
  ]
}
```

---

## Error Responses

All endpoints return errors in this format:

```json
{
  "error": true,
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

Common HTTP status codes:
- `400 Bad Request`: Invalid input
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Development

### Building

```bash
swift build
```

### Running in Development

```bash
swift run VoiceInkService
```

### Dependencies

- **VoiceInkCore**: Local Swift Package with core business logic
- **Vapor**: HTTP server framework

## Integration with Windows Shell

The Windows Avalonia app (VoiceInk.Windows) communicates with this service:

1. Start VoiceInkService as a background process
2. Send HTTP requests to `http://127.0.0.1:8787/api/*`
3. Handle JSON responses

See `WINDOWS_SHELL_ARCHITECTURE.md` for details.
