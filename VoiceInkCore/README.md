# VoiceInkCore

A platform-independent Swift Package providing the core business logic for VoiceInk voice transcription enhancement.

## Overview

VoiceInkCore contains all shared, platform-independent logic for:
- AI enhancement with multiple providers (Ollama, OpenAI, Anthropic, etc.)
- Transcription output filtering and post-processing
- Custom prompt management and templates
- Word replacement and vocabulary services
- Backend communication with AI providers

## Architecture

This package has ZERO platform-specific imports (no AppKit, SwiftUI, CoreAudio, etc.). All platform-specific functionality is abstracted through protocols in `Adapters/`.

### Modules

- **Models**: Core data models (Transcription, CustomPrompt, WordReplacement, etc.)
- **Prompts**: Prompt templates and management
- **Services**: Platform-independent business logic
- **Backends**: AI provider communication (Ollama, OpenAI-compatible)
- **Enhancement**: AI enhancement pipeline and filtering
- **Adapters**: Protocol definitions for platform-specific adapters
- **Settings**: Configuration constants

## Usage

### AI Enhancement

```swift
import VoiceInkCore

// Create a backend
let backend = OllamaBackend(
    baseURL: "http://localhost:11434",
    model: "llama2"
)

// Enhance text
let enhanced = try await backend.enhance(
    text: "um this is like a test",
    systemPrompt: AIPrompts.customPromptTemplate,
    temperature: 0.3
)

// Filter output
let filter = AIEnhancementOutputFilter()
let clean = filter.filter(enhanced)
```

### Prompt Management

```swift
// Get predefined prompts
let prompts = PredefinedPrompts.all

// Create custom prompt
let custom = CustomPrompt(
    title: "Code Review",
    promptText: "Review code for issues",
    icon: "curlybraces"
)

// Get final prompt text
let final = custom.finalPromptText()
```

### Word Replacement

```swift
let engine = WordReplacementEngine()
let replacements = [
    WordReplacement(originalText: "gonna", replacementText: "going to")
]
let result = engine.applyReplacements(to: text, using: replacements)
```

## Platform Integration

Platform-specific shells (macOS, Windows, iOS) implement the adapter protocols:
- `IAudioCapture` - Audio recording
- `IClipboardService` - Clipboard access
- `IContextProvider` - Window/text context
- `IGlobalShortcut` - Hotkey registration
- `INotificationService` - System notifications
- `IPasteService` - Text injection
- `ISecretStore` - Credential storage

## Testing

Run tests with:
```bash
swift test
```

All core logic is fully unit tested without platform dependencies.

## Requirements

- Swift 5.9+
- macOS 13+ / iOS 16+

## License

See LICENSE file in repository root.
