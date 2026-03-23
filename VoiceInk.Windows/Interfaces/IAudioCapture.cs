using System.Threading;
using System.Threading.Tasks;

namespace VoiceInk.Windows.Interfaces;

/// <summary>
/// Platform-specific audio capture abstraction.
/// Maps to Swift protocol of the same name in VoiceInkCore.
/// </summary>
public interface IAudioCapture
{
    bool IsRecording { get; }
    
    Task StartRecordingAsync(CancellationToken ct = default);
    Task<byte[]?> StopRecordingAsync(CancellationToken ct = default);
}
