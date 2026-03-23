using System;
using ReactiveUI;

namespace VoiceInk.Windows.Views;

/// <summary>
/// ViewModel for the system tray icon.
/// Exposes commands for the tray context menu.
/// </summary>
public class TrayIconViewModel : ReactiveObject
{
    public void ShowRecorder()
    {
        var window = new RecorderWindow();
        window.Show();
    }

    public void ShowSettings()
    {
        var window = new SettingsWindow();
        window.Show();
    }

    public void Quit()
    {
        Avalonia.Application.Current?.Lifetime is
            Avalonia.Controls.ApplicationLifetimes.IClassicDesktopStyleApplicationLifetime lifetime
            && lifetime.TryShutdown();
    }
}
