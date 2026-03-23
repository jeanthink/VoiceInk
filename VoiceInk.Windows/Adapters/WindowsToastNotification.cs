using System.Threading.Tasks;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Windows Toast notifications using Windows.UI.Notifications (WinRT).
/// Equivalent to NotificationManager.swift on macOS.
/// TODO: Implement using Microsoft.Windows.AppNotifications or WinRT interop
/// </summary>
public class WindowsToastNotification
{
    public Task ShowAsync(string title, string body, string identifier)
    {
        // TODO: Use Windows.UI.Notifications.ToastNotificationManager
        return Task.CompletedTask;
    }

    public Task ClearAsync(string identifier)
    {
        return Task.CompletedTask;
    }
}
