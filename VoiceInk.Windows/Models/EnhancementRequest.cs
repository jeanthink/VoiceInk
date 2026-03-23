namespace VoiceInk.Windows.Models;

public record EnhancementRequest(
    string Text,
    string? PromptId,
    string? CustomPromptText,
    string? SelectedText,
    string? ActiveUrl
);
