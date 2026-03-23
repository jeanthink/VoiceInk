using System;
using System.Runtime.InteropServices;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Global hotkey registration using Win32 RegisterHotKey API.
/// Equivalent to HotkeyManager.swift on macOS (uses Carbon/CGEvent).
/// </summary>
public class Win32GlobalShortcut : IDisposable
{
    private const int WM_HOTKEY = 0x0312;

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    public Action? OnActivate { get; set; }
    public Action? OnDeactivate { get; set; }

    private bool _registered;

    /// <summary>
    /// Register a global hotkey. modifiers: 0x1=Alt, 0x2=Ctrl, 0x4=Shift, 0x8=Win
    /// </summary>
    public bool Register(uint modifiers, uint virtualKey)
    {
        // TODO: Register with a message pump window
        _registered = true;
        return true;
    }

    public void Unregister()
    {
        _registered = false;
        // TODO: UnregisterHotKey
    }

    public void Dispose()
    {
        Unregister();
    }
}
