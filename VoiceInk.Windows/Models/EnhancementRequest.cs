namespace VoiceInk.Windows.Models;

public record EnhancementRequest(
    string Text,
    string Model,
    string? PromptId,
    string? SystemPrompt,
    double? Temperature,
    int? MaxTokens,
    string? SelectedText = null,  // Client-side only; not part of server contract
    string? ActiveUrl = null      // Client-side only; not part of server contract
);
