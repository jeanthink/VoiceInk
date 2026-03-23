using System;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using VoiceInk.Windows.Interfaces;

namespace VoiceInk.Windows.Adapters;

/// <summary>
/// Text paste simulation using Win32 SendInput API.
/// Equivalent to CursorPaster.swift on macOS (uses CGEvent).
/// Strategy: Save clipboard, set text, send Ctrl+V, restore clipboard.
/// </summary>
public class SendInputPasteService : IPasteService
{
    private readonly IClipboardService _clipboard;
    
    [DllImport("user32.dll")]
    private static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    private const int INPUT_KEYBOARD = 1;
    private const int KEYEVENTF_KEYUP = 0x0002;
    private const ushort VK_CONTROL = 0x11;
    private const ushort VK_V = 0x56;

    public SendInputPasteService(IClipboardService clipboard)
    {
        _clipboard = clipboard;
    }

    public async Task PasteAsync(string text)
    {
        await _clipboard.SaveAndClearAsync();
        await _clipboard.WriteTextAsync(text);

        // Brief delay for clipboard to settle
        await Task.Delay(50);

        SendCtrlV();

        // Brief delay for paste to complete
        await Task.Delay(100);

        await _clipboard.RestoreAsync();
    }

    private static void SendCtrlV()
    {
        var inputs = new[]
        {
            MakeKeyInput(VK_CONTROL, false),
            MakeKeyInput(VK_V, false),
            MakeKeyInput(VK_V, true),
            MakeKeyInput(VK_CONTROL, true),
        };
        SendInput((uint)inputs.Length, inputs, Marshal.SizeOf<INPUT>());
    }

    private static INPUT MakeKeyInput(ushort vk, bool keyUp)
    {
        return new INPUT
        {
            Type = INPUT_KEYBOARD,
            Data = new INPUTUNION
            {
                Keyboard = new KEYBDINPUT
                {
                    VirtualKey = vk,
                    Flags = keyUp ? (uint)KEYEVENTF_KEYUP : 0
                }
            }
        };
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct INPUT { public int Type; public INPUTUNION Data; }

    [StructLayout(LayoutKind.Explicit)]
    private struct INPUTUNION { [FieldOffset(0)] public KEYBDINPUT Keyboard; }

    [StructLayout(LayoutKind.Sequential)]
    private struct KEYBDINPUT
    {
        public ushort VirtualKey;
        public ushort ScanCode;
        public uint Flags;
        public uint Time;
        public IntPtr ExtraInfo;
    }
}
