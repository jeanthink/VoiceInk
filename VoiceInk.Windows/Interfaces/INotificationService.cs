using System.Threading.Tasks;

namespace VoiceInk.Windows.Interfaces;

/// <summary>
/// Platform-specific notification display.
/// Maps to Swift protocol of the same name in VoiceInkCore.
/// </summary>
public interface INotificationService
{
    Task ShowAsync(string title, string body, string identifier);
    Task ClearAsync(string identifier);
}
