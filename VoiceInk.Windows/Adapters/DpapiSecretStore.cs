using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using VoiceInk.Windows.Interfaces;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Secure secret storage using Windows DPAPI (Data Protection API).
/// Equivalent to KeychainService.swift on macOS.
/// Secrets are encrypted with the current user's credentials and stored in local app data.
/// </summary>
public class DpapiSecretStore : ISecretStore
{
    private readonly string _storePath;

    public DpapiSecretStore()
    {
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        var voiceInkDir = Path.Combine(appData, "VoiceInk");
        Directory.CreateDirectory(voiceInkDir);
        _storePath = Path.Combine(voiceInkDir, "secrets");
        Directory.CreateDirectory(_storePath);
    }

    public void Save(string key, string value)
    {
        var plainBytes = Encoding.UTF8.GetBytes(value);
        var encryptedBytes = ProtectedData.Protect(
            plainBytes,
            entropy: null,
            scope: DataProtectionScope.CurrentUser
        );
        
        var filePath = GetFilePath(key);
        File.WriteAllBytes(filePath, encryptedBytes);
    }

    public string? Load(string key)
    {
        var filePath = GetFilePath(key);
        if (!File.Exists(filePath))
            return null;
            
        try
        {
            var encryptedBytes = File.ReadAllBytes(filePath);
            var plainBytes = ProtectedData.Unprotect(
                encryptedBytes,
                entropy: null,
                scope: DataProtectionScope.CurrentUser
            );
            return Encoding.UTF8.GetString(plainBytes);
        }
        catch
        {
            return null;
        }
    }

    public void Delete(string key)
    {
        var filePath = GetFilePath(key);
        if (File.Exists(filePath))
            File.Delete(filePath);
    }
    
    private string GetFilePath(string key)
    {
        var safeKey = Convert.ToBase64String(Encoding.UTF8.GetBytes(key))
            .Replace('/', '_')
            .Replace('+', '-');
        return Path.Combine(_storePath, safeKey);
    }
}
