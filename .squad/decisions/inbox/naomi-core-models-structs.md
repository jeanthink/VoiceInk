# VoiceInkCore Models Are Structs, Not SwiftData Classes

**Date**: 2026-03-23  
**Author**: Naomi  
**Status**: Implemented

## Decision

All data models in VoiceInkCore are plain Swift structs conforming to `Codable` and `Identifiable`, NOT SwiftData `@Model` classes.

## Context

The VoiceInkCore package must be platform-independent to support macOS, Windows, iOS, and Linux. SwiftData's `@Model` macro is tied to Apple platforms and violates platform-independence.

## Consequences

**Platform Independence**: Works on any Swift-supported platform
**Serialization**: Easy JSON encoding/decoding for HTTP APIs
**Platform Adapters Must Handle Persistence**: Each platform shell manages its own data storage

## Team Impact

Use `struct`, not `@Model`. Conform to `Codable` and `Identifiable`. Don't import `SwiftData` in VoiceInkCore.
