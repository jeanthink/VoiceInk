using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using VoiceInk.Windows.Services;

namespace VoiceInk.Windows;

public partial class App : Application
{
    private CoreOrchestrator? _orchestrator;

    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);
    }

    public override void OnFrameworkInitializationCompleted()
    {
        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            _orchestrator = new CoreOrchestrator(
                voiceInkServiceBaseUrl: "http://127.0.0.1:7523"
            );

            // Tray-only app — no main window on startup
            desktop.MainWindow = null;
            desktop.ShutdownMode = Avalonia.Controls.ShutdownMode.OnExplicitShutdown;

            InitializeTrayIcon();
        }

        base.OnFrameworkInitializationCompleted();
    }

    private void InitializeTrayIcon()
    {
        // TODO: Implement tray icon with NativeMenu
    }
}
