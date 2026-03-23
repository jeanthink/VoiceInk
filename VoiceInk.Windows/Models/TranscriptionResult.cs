using System;

namespace VoiceInk.Windows.Models;

public record TranscriptionResult(
    string Text,
    string ModelId,
    TimeSpan Duration,
    float Confidence
);
