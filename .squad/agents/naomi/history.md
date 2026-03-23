# Naomi — History

## Core Context

- **Project:** Cross-platform VoiceInk — extract a Swift Package core from the existing macOS app, wrap it in a local HTTP service, and build an Avalonia Windows shell that calls it, while preserving the existing macOS SwiftUI app.
- **Role:** Swift Core Dev
- **Joined:** 2026-03-23T00:37:36.338Z

## Learnings

<!-- Append learnings below -->

## 2026-03-23: VoiceInkCore Swift Package Creation

### Task
Created VoiceInkCore as a standalone Swift Package with zero platform dependencies.

### Key Decisions
- **Architecture**: Followed Path A from DECISIONS.md — Swift Package Core with adapter protocols
- **Platform Independence**: Zero imports of AppKit, SwiftUI, CoreAudio, Carbon, AVFoundation
- **Testing**: Full unit test coverage (41 tests) for all core components
- **Structure**: Modular organization by concern (Models, Prompts, Services, Backends, Enhancement, Adapters)

### Components Created

**Models** (4 files):
- Transcription - core transcription data model (struct, not SwiftData @Model)
- VocabularyWord, WordReplacement, TranscriptionModel

**Prompts** (4 files):
- CustomPrompt - full JSON encoding/decoding, finalPromptText() method
- AIPrompts - system instruction templates
- PromptTemplates - predefined prompt library (Default, Chat, Email, Rewrite)
- PredefinedPrompts - default & assistant modes

**Services** (3 files):
- TranscriptionOutputFilter - hallucination removal, filler words, tag cleanup
- WordReplacementService - platform-independent word replacement engine with CJK support
- VocabularyFormatter - context assembly for AI prompts

**Backends** (2 files):
- OllamaBackend - URLSession-based Ollama API client
- OpenAICompatibleBackend - OpenAI-compatible API client with reasoning support

**Enhancement** (3 files):
- AIProvider - 11 provider definitions (Ollama, OpenAI, Groq, Anthropic, etc.)
- ReasoningConfig - o1/o3 model reasoning effort configuration
- AIEnhancementOutputFilter - removes <thinking>, <reasoning> tags

**Adapters** (1 file):
- Protocols - 7 adapter protocols for platform integration

**Tests** (6 test files, 41 tests):
- AIEnhancementOutputFilterTests
- CustomPromptTests (JSON round-trip, system instructions)
- TranscriptionOutputFilterTests
- WordReplacementServiceTests
- PromptTemplatesTests
- AIProviderTests

### Key Patterns
- **Data Models**: Structs with Codable, not SwiftData @Model (platform-independent)
- **Services**: Pure functions or structs with no state dependencies
- **Backends**: Protocol-based with URLSession (no external dependencies)
- **Configuration**: Passed as parameters, not read from UserDefaults

### File Paths
- `/VoiceInkCore/Package.swift` - Swift Package manifest
- `/VoiceInkCore/Sources/VoiceInkCore/` - all source code
- `/VoiceInkCore/Tests/VoiceInkCoreTests/` - unit tests
- `/VoiceInkCore/README.md` - package documentation

### Build Verification
- ✅ `swift build` - clean build, no errors
- ✅ `swift test` - 41 tests passing
- ✅ No platform-specific imports detected

### Pull Request
- PR #12: https://github.com/jeanthink/VoiceInk/pull/12
- Branch: squad/naomi-voiceinkcore-polish
- Status: Ready for review
