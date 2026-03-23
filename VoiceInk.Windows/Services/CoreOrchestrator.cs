using System;
using System.Threading;
using System.Threading.Tasks;
using VoiceInk.Windows.Adapters;

namespace VoiceInk.Windows.Services;

/// <summary>
/// Wires together platform adapters and the VoiceInkService HTTP client.
/// This is the main coordinator for the Windows shell.
/// </summary>
public class CoreOrchestrator : IDisposable
{
    private readonly VoiceInkHttpClient _coreClient;
    private readonly WasapiAudioCapture _audioCapture;
    private readonly Win32GlobalShortcut _globalShortcut;
    private readonly WindowsClipboardService _clipboard;
    private readonly SendInputPasteService _paste;
    private readonly WindowsToastNotification _notifications;
    private readonly DpapiSecretStore _secrets;

    public CoreOrchestrator(string voiceInkServiceBaseUrl)
    {
        _coreClient = new VoiceInkHttpClient(voiceInkServiceBaseUrl);
        _audioCapture = new WasapiAudioCapture();
        _globalShortcut = new Win32GlobalShortcut();
        _clipboard = new WindowsClipboardService();
        _paste = new SendInputPasteService();
        _notifications = new WindowsToastNotification();
        _secrets = new DpapiSecretStore();
    }

    /// <summary>
    /// Start a recording session. Audio captured via WASAPI.
    /// When stopped, audio is sent to VoiceInkService for transcription.
    /// </summary>
    public async Task StartRecordingAsync(CancellationToken ct = default)
    {
        await _audioCapture.StartRecordingAsync(ct);
    }

    public async Task<string?> StopRecordingAndTranscribeAsync(
        string modelId,
        CancellationToken ct = default)
    {
        var audioData = await _audioCapture.StopRecordingAsync(ct);
        if (audioData == null || audioData.Length == 0) return null;

        // TODO: Send to VoiceInkService when API is ready
        return null;
    }

    public void Dispose()
    {
        _coreClient.Dispose();
        _audioCapture.Dispose();
        _globalShortcut.Dispose();
    }
}
