namespace VoiceInk.Windows.Models;

public record ModelInfo(
    string Id,
    string Name,
    string Provider,
    bool IsLocal,
    bool IsAvailable
);
