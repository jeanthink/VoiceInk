using System;

namespace VoiceInk.Windows.Interfaces;

/// <summary>
/// Platform-specific global hotkey registration.
/// Maps to Swift protocol of the same name in VoiceInkCore.
/// </summary>
public interface IGlobalShortcut
{
    Action? OnActivate { get; set; }
    Action? OnDeactivate { get; set; }
    
    bool Register(uint modifiers, uint virtualKey);
    void Unregister();
}
