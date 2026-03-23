using System.Collections.Generic;
using System.Threading.Tasks;
using VoiceInk.Windows.Interfaces;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Windows Toast notifications using Windows.UI.Notifications (WinRT).
/// Equivalent to NotificationManager.swift on macOS.
/// TODO: Implement using Microsoft.Toolkit.Uwp.Notifications or WinRT interop
/// </summary>
public class WindowsToastNotification : INotificationService
{
    private readonly Dictionary<string, object> _activeNotifications = new();
    
    public Task ShowAsync(string title, string body, string identifier)
    {
        // TODO: Use Windows.UI.Notifications.ToastNotificationManager
        // Example structure:
        // var toastXml = ToastNotificationManager.GetTemplateContent(ToastTemplateType.ToastText02);
        // var textNodes = toastXml.GetElementsByTagName("text");
        // textNodes[0].AppendChild(toastXml.CreateTextNode(title));
        // textNodes[1].AppendChild(toastXml.CreateTextNode(body));
        // var toast = new ToastNotification(toastXml) { Tag = identifier };
        // ToastNotificationManager.CreateToastNotifier().Show(toast);
        // _activeNotifications[identifier] = toast;
        
        return Task.CompletedTask;
    }

    public Task ClearAsync(string identifier)
    {
        // TODO: Use ToastNotificationManager to clear notification by tag
        // if (_activeNotifications.TryGetValue(identifier, out var toast))
        // {
        //     ToastNotificationManager.History.Remove(identifier);
        //     _activeNotifications.Remove(identifier);
        // }
        
        return Task.CompletedTask;
    }
}
