using System.Threading.Tasks;
using Avalonia;
using Avalonia.Input.Platform;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Clipboard access on Windows.
/// Equivalent to ClipboardManager.swift on macOS.
/// Uses Avalonia's cross-platform clipboard abstraction.
/// </summary>
public class WindowsClipboardService
{
    private string? _savedContent;

    public async Task<string?> ReadTextAsync()
    {
        var clipboard = Application.Current?.Clipboard;
        if (clipboard == null) return null;
        return await clipboard.GetTextAsync();
    }

    public async Task WriteTextAsync(string text)
    {
        var clipboard = Application.Current?.Clipboard;
        if (clipboard == null) return;
        await clipboard.SetTextAsync(text);
    }

    public async Task<string?> SaveAndClearAsync()
    {
        _savedContent = await ReadTextAsync();
        return _savedContent;
    }

    public async Task RestoreAsync()
    {
        if (_savedContent != null)
            await WriteTextAsync(_savedContent);
    }
}
