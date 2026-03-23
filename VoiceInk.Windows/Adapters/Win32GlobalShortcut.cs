using System;
using System.Runtime.InteropServices;
using VoiceInk.Windows.Interfaces;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Global hotkey registration using Win32 RegisterHotKey API.
/// Equivalent to HotkeyManager.swift on macOS (uses Carbon/CGEvent).
/// Requires a message pump window handle to receive WM_HOTKEY messages.
/// </summary>
public class Win32GlobalShortcut : IGlobalShortcut, IDisposable
{
    private const int WM_HOTKEY = 0x0312;
    private const int HOTKEY_ID = 9000;
    
    // Win32 modifier flags
    public const uint MOD_ALT = 0x0001;
    public const uint MOD_CONTROL = 0x0002;
    public const uint MOD_SHIFT = 0x0004;
    public const uint MOD_WIN = 0x0008;

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    public Action? OnActivate { get; set; }
    public Action? OnDeactivate { get; set; }

    private IntPtr _hWnd;
    private bool _registered;

    /// <summary>
    /// Register a global hotkey. modifiers: 0x1=Alt, 0x2=Ctrl, 0x4=Shift, 0x8=Win
    /// </summary>
    public bool Register(uint modifiers, uint virtualKey)
    {
        if (_registered)
            Unregister();
            
        // TODO: Get actual window handle from Avalonia main window
        // For now, use IntPtr.Zero (message-only window approach)
        _hWnd = IntPtr.Zero;
        
        _registered = RegisterHotKey(_hWnd, HOTKEY_ID, modifiers, virtualKey);
        
        if (_registered)
        {
            // TODO: Wire up WndProc hook or Avalonia message filter to receive WM_HOTKEY
            // When WM_HOTKEY (0x0312) arrives with wParam == HOTKEY_ID:
            //   - Invoke OnActivate on key down
            //   - Invoke OnDeactivate on key up (if hold-to-record behavior needed)
        }
        
        return _registered;
    }

    public void Unregister()
    {
        if (_registered)
        {
            UnregisterHotKey(_hWnd, HOTKEY_ID);
            _registered = false;
        }
    }

    public void Dispose()
    {
        Unregister();
    }
}
