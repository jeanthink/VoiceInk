using System.Threading.Tasks;

namespace VoiceInk.Windows.Interfaces;

/// <summary>
/// Platform-specific clipboard access.
/// Maps to Swift protocol of the same name in VoiceInkCore.
/// </summary>
public interface IClipboardService
{
    Task<string?> ReadTextAsync();
    Task WriteTextAsync(string text);
    Task<string?> SaveAndClearAsync();
    Task RestoreAsync();
}
