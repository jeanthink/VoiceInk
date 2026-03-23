# VoiceInk Cross-Platform Architecture Decisions

This file is the authoritative record of every architectural decision made during
cross-platform planning. It supersedes any conflicting sections in the other planning
documents.

---

## Decision 1: Target Platforms

**Chosen:** Windows (primary new target), macOS (existing), Linux (later), iOS (future)

**Rationale:** The existing product runs on macOS. The immediate business goal is a
Windows version. Linux is a stretch goal. iOS is a genuine future target, not a
hypothetical.

---

## Decision 2: Architecture Pattern — Path A (Swift Package Core)

**Chosen:** Extract a Swift Package core from the existing macOS app. Keep the macOS
SwiftUI app largely intact. Build a Windows shell (Avalonia or WinUI) that communicates
with the Swift core. iOS uses the Swift Package natively in future.

**Rejected:** Path B — rewrite the business logic in C# and build Avalonia shells for
all platforms.

### Why Path A was chosen over Path B

| Factor | Path A: Swift Package Core | Path B: C# Avalonia Rewrite |
|---|---|---|
| macOS app today | Preserved, minimal rework | Must be fully rewritten |
| Existing SwiftUI views | Reusable on iOS | Abandoned entirely |
| iOS later | Natural — Swift Package + SwiftUI | Requires separate MAUI rewrite |
| Windows shell | Avalonia or WinUI calling Swift core | Avalonia with C# core |
| Linux shell | Avalonia calling Swift core | Avalonia with C# core |
| Two UI frameworks needed? | Yes — SwiftUI + Avalonia/WinUI | Yes — Avalonia + MAUI (if iOS) |
| Upfront rewrite cost | Low — extract, don't rewrite | High — full C# rewrite |

**The decisive reason Path B was rejected:** If iOS is ever in scope, Avalonia cannot
run on iOS at all. Reaching iOS from a C# core requires .NET MAUI, which is a second
UI framework. That means Path B still requires two UI frameworks but also throws away
all existing Swift code. Path A requires two UI frameworks (SwiftUI + Avalonia/WinUI)
but preserves the entire existing macOS app and gives iOS a natural extension path.

### Framework coverage by platform

| Platform | SwiftUI | Avalonia | .NET MAUI |
|---|---|---|---|
| macOS | ✅ | ✅ | ✅ (poor) |
| iOS | ✅ | ❌ | ✅ |
| Windows | ❌ | ✅ | ✅ |
| Linux | ❌ | ✅ | ❌ |
| Android | ❌ | ❌ | ✅ |

No single framework covers iOS + Windows + Linux. This is a fixed constraint of the
current ecosystem.

### What this means for the decision

Because no single UI framework spans all four targets, any cross-platform strategy
requires two UI frameworks. The question is only which combination throws away the
least existing work:

- **Path B (C# Avalonia):** requires Avalonia for desktop + MAUI for iOS. The entire
  existing Swift app is abandoned. Two frameworks, zero reuse.
- **Path A (Swift Package Core):** requires SwiftUI for Apple platforms + Avalonia
  for Windows/Linux. The existing macOS app is preserved. iOS is a natural extension.
  Two frameworks, high reuse.

Path A wins because both paths pay the two-framework cost, but only Path A preserves
what is already built.

### The iOS constraint that drove this decision

- **SwiftUI** runs on: macOS, iOS, iPadOS, watchOS, tvOS — not Windows, not Linux
- **Avalonia** runs on: Windows, macOS, Linux desktop — not iOS, not Android
- **No single framework** covers iOS + Windows + Linux today
- **.NET MAUI** covers iOS + Android + Windows + macOS (poor) — no Linux
- **Swift Package Manager** runs on all Apple platforms and experimentally on Windows/Linux

If iOS is a real goal, the only path that does not require throwing away existing work
is to keep the core in Swift.

---

## Decision 3: Shared Core Technology

**Chosen:** Swift Package Manager library (`VoiceInk.Core` as a Swift Package)

**Rejected:** C# class library (`VoiceInk.Core` as a .NET project)

### What the Swift Package core owns

- Transcription model selection and provider routing
- AI enhancement pipeline (prompt selection, context assembly, output filtering)
- Local LLM backend abstraction (Ollama-compatible, OpenAI-compatible endpoints)
- Prompt templates, custom prompts, vocabulary injection
- Settings and configuration models
- All HTTP-based provider calls (cloud and local)

### What the Swift Package core does NOT own

- Any AppKit, SwiftUI, UIKit, or platform UI import
- Any CoreAudio, Carbon, or macOS-specific framework import
- Any platform-specific credential storage
- Any platform-specific clipboard, hotkey, or accessibility logic

---

## Decision 4: macOS App Strategy

**Chosen:** Keep the existing macOS SwiftUI app. Restructure it to depend on the
extracted Swift Package core rather than rewriting it.

**Rationale:** The existing app already works. The refactor cost to extract the Swift
Package is far lower than a full rewrite. After extraction, the macOS app becomes the
reference implementation for correct behavior on all other platforms.

---

## Decision 5: Windows Shell Technology

**Chosen:** Avalonia (C#) calling the Swift Package core over a local HTTP service
or C ABI interop boundary.

**Why Avalonia for Windows:**
- Strong Windows desktop support
- Tray icon, custom windowing, and input integration work well
- Active community and commercial backing
- Covers Linux too when that milestone arrives

**The interop seam:** Because the Swift Package core is Swift and the Windows shell
is C#, there is a boundary between them. The two practical options are:

1. **Local HTTP service** — the Swift core runs as a background process exposing a
   local REST or gRPC API; the C# Avalonia shell calls it. Clear separation, easier
   to debug, slight overhead.
2. **C ABI interop** — the Swift Package exports a C-compatible interface; the C#
   shell calls it via P/Invoke. Tighter coupling, more complex to maintain.

**Recommended starting point:** Local HTTP service. It is simpler to develop and test,
and the latency cost for a voice workflow is negligible.

---

## Decision 6: iOS Strategy

**Chosen:** Defer iOS to a future milestone. When it arrives, the iOS app is a new
Swift Package Manager target (or an app target) that imports `VoiceInk.Core` directly.
SwiftUI views from the macOS app can be adapted with moderate effort since SwiftUI is
shared across Apple platforms.

**No work is needed now** to support this future. The Swift Package extraction in
Decision 3 is the only prerequisite.

---

## Decision 7: Linux Strategy

**Chosen:** Defer Linux to after Windows is stable. When it arrives, the Linux shell
follows the same Avalonia + local HTTP service pattern as Windows, calling into the
same Swift Package core running as a background process.

---

## Decision 8: Local Model Strategy (all platforms)

**Chosen:** Ollama-compatible local servers as the primary local path for both
transcription enhancement and prompt rewriting. Platform speech APIs are optional
adapters, not the product identity.

Priority order:
1. Ollama-compatible local LLM backends for rewriting and enhancement
2. whisper.cpp or equivalent for local speech transcription
3. Platform speech APIs (Windows Speech, macOS SpeechTranscriber) as optional fallback

This is the product's privacy and user-ownership story and must not be compromised
by platform-specific convenience integrations.

---

## Relationship Between This Decision and the Existing Planning Documents

The other planning documents in this repo were written during an earlier phase of
planning when Path B (C# Avalonia rewrite) was the working direction. They contain
useful structural thinking that still applies, but the technology references need
to be read through the lens of the decisions above.

### What still applies from those documents

**From CROSS_PLATFORM_PLAN.md:**
- The phase structure (shared core first, then Windows shell, then stabilize, then
  advanced context features) is correct regardless of language
- The capability map (audio, hotkeys, clipboard, paste, notifications, tray, optional
  context providers) is accurate for any platform shell
- The verification checklist logic is still valid — just substitute Swift Package
  for C# class library
- The local model strategy section is accurate and unchanged

**From WINDOWS_SHELL_ARCHITECTURE.md:**
- The layering (shell → adapters → core → optional context) is the right structure
- The per-platform adapter tables (WASAPI, Win32, DXGI, etc.) are accurate for the
  Windows Avalonia shell regardless of what the core language is
- The UX conventions table (tray vs menu bar, etc.) is accurate
- The architecture rules are still valid — substitute Swift Package for C# core

**From IMPLEMENTATION_BACKLOG.md:**
- The adapter interface concepts (IAudioCapture, IGlobalShortcut, etc.) are still the
  right abstractions — they become Swift protocols in the Swift Package and C#
  interfaces in the Avalonia shell
- The milestone structure is still the right sequence
- The acceptance criteria are still valid

### What is now superseded

- Any reference to `VoiceInk.Core` as a C# class library → becomes a Swift Package
- Any reference to rewriting Swift logic in C# → becomes extracting Swift logic into
  a Swift Package
- Any reference to the macOS app being rewritten → the macOS app is preserved and
  restructured to depend on the Swift Package
- Any reference to `VoiceInk.macOS` as an Avalonia project → the macOS app stays
  as the existing SwiftUI project
- The solution layout showing five .NET projects → becomes a Swift Package + one
  Avalonia project (Windows) + existing Xcode project (macOS)

---

## Revised Solution Layout

```
VoiceInk/                          existing Xcode project (macOS SwiftUI app)
  VoiceInk/                        app target — depends on VoiceInkCore package
  ...

VoiceInkCore/                      NEW: Swift Package
  Sources/VoiceInkCore/
    Transcription/                 model selection, provider routing
    Enhancement/                   prompt pipeline, output filter, vocabulary
    Backends/                      OllamaBackend, OpenAICompatibleBackend
    Prompts/                       CustomPrompt, PromptTemplate, PromptRegistry
    Settings/                      AppSettings, ISecretStore protocol
    Adapters/                      Swift protocols: IAudioCapture, IGlobalShortcut,
                                   IClipboardService, IPasteService, INotification,
                                   IContextProvider
  Tests/VoiceInkCoreTests/

VoiceInkService/                   NEW: thin HTTP service wrapping VoiceInkCore
                                   exposes local REST/gRPC API for non-Swift shells

VoiceInk.Windows/                  NEW: Avalonia C# project
  Adapters/                        WasapiAudioCapture, Win32GlobalShortcut,
                                   WindowsClipboard, SendInputPaste,
                                   WindowsToastNotification, DpapiSecretStore
  Views/                           Avalonia AXAML views
  App.axaml.cs                     calls VoiceInkService over local HTTP
```

The iOS app, when it arrives, becomes a new Xcode target that imports `VoiceInkCore`
directly via Swift Package Manager — no HTTP boundary, no interop.

---

## Open Questions

1. **Interop boundary for Windows:** Local HTTP service vs C ABI. Recommend HTTP
   first, revisit if latency is ever a problem.
2. **Linux timing:** After Windows MVP is stable and used in production.
3. **iOS timing:** After the Swift Package extraction is complete and stable on macOS.
4. **VoiceInkService hosting:** The Swift service process needs to start with the
   Windows app, stay running in the background, and shut down cleanly. This requires
   a process lifecycle strategy in the Avalonia shell.

---

## Immediate Next Steps

1. Extract `VoiceInkCore` as a Swift Package from the existing Xcode project
2. Refactor the macOS app to import `VoiceInkCore` and confirm all existing behavior
   is preserved
3. Add a thin HTTP service wrapper (`VoiceInkService`) around `VoiceInkCore`
4. Create the `VoiceInk.Windows` Avalonia project and implement Windows adapters
5. Wire the Avalonia shell to call `VoiceInkService` for all core product operations
