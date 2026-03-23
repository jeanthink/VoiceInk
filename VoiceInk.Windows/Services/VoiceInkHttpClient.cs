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
            Timeout = TimeSpan.FromSeconds(30)
        };
    }

    public async Task<bool> IsHealthyAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _http.GetAsync("/health", ct);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    public Task<TranscriptionResult?> TranscribeAsync(
        byte[] audioData,
        string modelId,
        CancellationToken ct = default)
    {
        // TODO: Implement multipart form upload for audio data
        // POST /transcribe with audio bytes + model ID
        throw new NotImplementedException("Implement when VoiceInkService API is finalized");
    }

    public async Task<string?> EnhanceAsync(
        EnhancementRequest request,
        CancellationToken ct = default)
    {
        var response = await _http.PostAsJsonAsync("/enhance", request, ct);
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<EnhancementResult>(cancellationToken: ct);
        return result?.EnhancedText;
    }

    public async Task<ModelInfo[]> GetModelsAsync(CancellationToken ct = default)
    {
        var models = await _http.GetFromJsonAsync<ModelInfo[]>("/models", ct);
        return models ?? Array.Empty<ModelInfo>();
    }

    public void Dispose()
    {
        _http.Dispose();
    }
}

public record EnhancementResult(string EnhancedText);
