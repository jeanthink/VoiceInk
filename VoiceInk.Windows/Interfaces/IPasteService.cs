using System.Threading.Tasks;

namespace VoiceInk.Windows.Interfaces;

/// <summary>
/// Platform-specific text paste simulation.
/// Maps to Swift protocol of the same name in VoiceInkCore.
/// </summary>
public interface IPasteService
{
    Task PasteAsync(string text);
}
