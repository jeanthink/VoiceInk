using System;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Secure secret storage using Windows DPAPI (Data Protection API).
/// Equivalent to KeychainService.swift on macOS.
/// Secrets are encrypted with the current user's credentials.
/// TODO: Replace env var stub with ProtectedData.Protect (DPAPI) + registry/file storage
/// </summary>
public class DpapiSecretStore
{
    public void Save(string key, string value)
    {
        // TODO: ProtectedData.Protect(Encoding.UTF8.GetBytes(value), null, DataProtectionScope.CurrentUser)
        Environment.SetEnvironmentVariable($"VOICEINK_{key}", value, EnvironmentVariableTarget.User);
    }

    public string? Load(string key)
    {
        return Environment.GetEnvironmentVariable($"VOICEINK_{key}", EnvironmentVariableTarget.User);
    }

    public void Delete(string key)
    {
        Environment.SetEnvironmentVariable($"VOICEINK_{key}", null, EnvironmentVariableTarget.User);
    }
}
