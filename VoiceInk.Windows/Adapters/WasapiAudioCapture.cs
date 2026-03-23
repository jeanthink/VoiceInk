using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using VoiceInk.Windows.Interfaces;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Windows audio capture using WASAPI (Windows Audio Session API).
/// Equivalent to CoreAudioRecorder.swift on macOS.
/// Uses NAudio for WASAPI capture, records PCM 16kHz mono for Whisper compatibility.
/// </summary>
public class WasapiAudioCapture : IAudioCapture, IDisposable
{
    private readonly List<byte> _audioBuffer = new();
    private readonly object _bufferLock = new();
    
    // TODO: Replace with actual NAudio.Wave.WasapiCapture when NAudio package is added
    // private WasapiCapture? _capture;
    
    public bool IsRecording { get; private set; }

    public Task StartRecordingAsync(CancellationToken ct = default)
    {
        lock (_bufferLock)
        {
            _audioBuffer.Clear();
        }
        
        // TODO: Initialize NAudio WASAPI capture
        // _capture = new WasapiCapture();
        // _capture.WaveFormat = new WaveFormat(16000, 16, 1); // 16kHz, 16-bit, mono
        // _capture.DataAvailable += OnDataAvailable;
        // _capture.StartRecording();
        
        IsRecording = true;
        return Task.CompletedTask;
    }

    public Task<byte[]?> StopRecordingAsync(CancellationToken ct = default)
    {
        IsRecording = false;
        
        // TODO: Stop NAudio capture
        // _capture?.StopRecording();
        // await Task.Delay(100, ct); // Allow final buffer flush
        
        byte[]? result;
        lock (_bufferLock)
        {
            result = _audioBuffer.Count > 0 ? _audioBuffer.ToArray() : null;
            _audioBuffer.Clear();
        }
        
        return Task.FromResult(result);
    }
    
    private void OnDataAvailable(object? sender, EventArgs e)
    {
        // TODO: Wire with NAudio's DataAvailable event
        // var args = (WaveInEventArgs)e;
        // lock (_bufferLock)
        // {
        //     _audioBuffer.AddRange(args.Buffer[..args.BytesRecorded]);
        // }
    }

    public void Dispose()
    {
        // TODO: Dispose NAudio resources
        // _capture?.Dispose();
        lock (_bufferLock)
        {
            _audioBuffer.Clear();
        }
    }
}
