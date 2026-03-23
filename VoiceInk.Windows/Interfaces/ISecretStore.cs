namespace VoiceInk.Windows.Interfaces;

/// <summary>
/// Platform-specific secure secret storage.
/// Maps to Swift protocol of the same name in VoiceInkCore.
/// </summary>
public interface ISecretStore
{
    void Save(string key, string value);
    string? Load(string key);
    void Delete(string key);
}
