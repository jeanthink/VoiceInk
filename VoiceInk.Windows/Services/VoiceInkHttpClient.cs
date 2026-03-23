using System;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading;
using System.Threading.Tasks;
using VoiceInk.Windows.Models;

namespace VoiceInk.Windows.Services;

/// <summary>
/// HTTP client for communicating with VoiceInkService (the Swift HTTP bridge).
/// VoiceInkService runs as a background process alongside VoiceInk.Windows
/// and exposes the Swift core's functionality over a local REST API.
/// </summary>
public class VoiceInkHttpClient : IDisposable
{
    private readonly HttpClient _http;

    public VoiceInkHttpClient(string baseUrl = "http://127.0.0.1:7523")
    {
        _http = new HttpClient
        {
            BaseAddress = new Uri(baseUrl),
            Timeout = TimeSpan.FromSeconds(120) // Transcription can be slow
        };
    }

    /// <summary>
    /// Health check to verify VoiceInkService is running and responsive.
    /// GET /api/health
    /// </summary>
    public async Task<bool> HealthCheckAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _http.GetAsync("/api/health", ct);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Send audio data for transcription.
    /// POST /api/transcribe
    /// Content-Type: multipart/form-data
    /// Body: audio file (PCM/WAV), model ID
    /// </summary>
    public async Task<TranscriptionResult?> TranscribeAsync(
        byte[] audioData,
        string modelId = "whisper-1",
        CancellationToken ct = default)
    {
        using var content = new MultipartFormDataContent();
        content.Add(new ByteArrayContent(audioData), "audio", "recording.wav");
        content.Add(new StringContent(modelId), "model");

        var response = await _http.PostAsync("/api/transcribe", content, ct);
        
        if (!response.IsSuccessStatusCode)
            return null;
            
        return await response.Content.ReadFromJsonAsync<TranscriptionResult>(cancellationToken: ct);
    }

    /// <summary>
    /// Send text for AI enhancement (rewrite with prompt).
    /// POST /api/enhance
    /// Content-Type: application/json
    /// Body: EnhancementRequest
    /// </summary>
    public async Task<string?> EnhanceAsync(
        EnhancementRequest request,
        CancellationToken ct = default)
    {
        var response = await _http.PostAsJsonAsync("/api/enhance", request, ct);
        
        if (!response.IsSuccessStatusCode)
            return null;
            
        var result = await response.Content.ReadFromJsonAsync<EnhancementResult>(cancellationToken: ct);
        return result?.EnhancedText;
    }

    /// <summary>
    /// List available transcription models.
    /// GET /api/models
    /// </summary>
    public async Task<ModelInfo[]> ListModelsAsync(CancellationToken ct = default)
    {
        try
        {
            var models = await _http.GetFromJsonAsync<ModelInfo[]>("/api/models", ct);
            return models ?? Array.Empty<ModelInfo>();
        }
        catch
        {
            return Array.Empty<ModelInfo>();
        }
    }

    public void Dispose()
    {
        _http.Dispose();
    }
}

public record EnhancementResult(string EnhancedText);
