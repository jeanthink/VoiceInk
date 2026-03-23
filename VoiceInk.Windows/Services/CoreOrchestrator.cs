using System;
using System.Threading;
using System.Threading.Tasks;
using VoiceInk.Windows.Adapters;
using VoiceInk.Windows.Interfaces;
using VoiceInk.Windows.Models;

namespace VoiceInk.Windows.Services;

/// <summary>
/// Wires together platform adapters and the VoiceInkService HTTP client.
/// This is the main coordinator for the Windows shell.
/// Orchestrates the full record→transcribe→enhance→paste flow.
/// </summary>
public class CoreOrchestrator : IDisposable
{
    private readonly VoiceInkHttpClient _coreClient;
    private readonly IAudioCapture _audioCapture;
    private readonly IGlobalShortcut _globalShortcut;
    private readonly IClipboardService _clipboard;
    private readonly IPasteService _paste;
    private readonly INotificationService _notifications;
    private readonly ISecretStore _secrets;

    private string _currentModelId = "whisper-1";
    private bool _isProcessing;

    public CoreOrchestrator(string voiceInkServiceBaseUrl)
    {
        _coreClient = new VoiceInkHttpClient(voiceInkServiceBaseUrl);
        _audioCapture = new WasapiAudioCapture();
        _globalShortcut = new Win32GlobalShortcut();
        _clipboard = new WindowsClipboardService();
        _paste = new SendInputPasteService(_clipboard);
        _notifications = new WindowsToastNotification();
        _secrets = new DpapiSecretStore();

        WireHotkeys();
    }

    private void WireHotkeys()
    {
        // TODO: Make hotkey configurable from settings
        // Default: Ctrl+Shift+Space (0x02 = Ctrl, 0x04 = Shift, 0x20 = Space)
        _globalShortcut.OnActivate = () => _ = StartRecordingAsync();
        _globalShortcut.OnDeactivate = () => _ = StopRecordingAndProcessAsync();
        
        _globalShortcut.Register(
            Win32GlobalShortcut.MOD_CONTROL | Win32GlobalShortcut.MOD_SHIFT,
            0x20 // VK_SPACE
        );
    }

    /// <summary>
    /// Start a recording session. Audio captured via WASAPI.
    /// </summary>
    public async Task StartRecordingAsync(CancellationToken ct = default)
    {
        if (_isProcessing || _audioCapture.IsRecording)
            return;

        await _notifications.ShowAsync(
            "VoiceInk",
            "Recording...",
            "recording"
        );

        await _audioCapture.StartRecordingAsync(ct);
    }

    /// <summary>
    /// Stop recording, send audio for transcription, enhance text, and paste result.
    /// Full pipeline: record → transcribe → enhance → paste
    /// </summary>
    public async Task StopRecordingAndProcessAsync(CancellationToken ct = default)
    {
        if (_isProcessing || !_audioCapture.IsRecording)
            return;

        _isProcessing = true;

        try
        {
            await _notifications.ClearAsync("recording");
            await _notifications.ShowAsync(
                "VoiceInk",
                "Processing...",
                "processing"
            );

            // Step 1: Stop recording and get audio data
            var audioData = await _audioCapture.StopRecordingAsync(ct);
            if (audioData == null || audioData.Length == 0)
            {
                await _notifications.ClearAsync("processing");
                await _notifications.ShowAsync(
                    "VoiceInk",
                    "No audio captured",
                    "error"
                );
                return;
            }

            // Step 2: Transcribe audio via VoiceInkService
            var transcription = await _coreClient.TranscribeAsync(audioData, _currentModelId, ct);
            if (transcription == null || string.IsNullOrWhiteSpace(transcription.Text))
            {
                await _notifications.ClearAsync("processing");
                await _notifications.ShowAsync(
                    "VoiceInk",
                    "Transcription failed",
                    "error"
                );
                return;
            }

            // Step 3: Enhance text via VoiceInkService (if configured)
            // TODO: Check if enhancement is enabled in settings
            var enhancementRequest = new EnhancementRequest(
                Text: transcription.Text,
                PromptId: null, // Use default prompt
                CustomPromptText: null,
                SelectedText: null,
                ActiveUrl: null
            );

            var enhancedText = await _coreClient.EnhanceAsync(enhancementRequest, ct);
            var finalText = enhancedText ?? transcription.Text;

            // Step 4: Paste the result
            await _paste.PasteAsync(finalText);

            await _notifications.ClearAsync("processing");
            await _notifications.ShowAsync(
                "VoiceInk",
                "Pasted successfully",
                "success"
            );
        }
        catch (Exception ex)
        {
            await _notifications.ClearAsync("processing");
            await _notifications.ShowAsync(
                "VoiceInk",
                $"Error: {ex.Message}",
                "error"
            );
        }
        finally
        {
            _isProcessing = false;
        }
    }

    /// <summary>
    /// Set the current transcription model.
    /// </summary>
    public void SetModel(string modelId)
    {
        _currentModelId = modelId;
    }

    /// <summary>
    /// Get available models from VoiceInkService.
    /// </summary>
    public Task<ModelInfo[]> GetModelsAsync(CancellationToken ct = default)
    {
        return _coreClient.ListModelsAsync(ct);
    }

    /// <summary>
    /// Check if VoiceInkService is healthy and responsive.
    /// </summary>
    public Task<bool> CheckServiceHealthAsync(CancellationToken ct = default)
    {
        return _coreClient.HealthCheckAsync(ct);
    }

    public void Dispose()
    {
        _globalShortcut.Dispose();
        _audioCapture.Dispose();
        _coreClient.Dispose();
    }
}
