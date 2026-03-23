import AppKit

/// macOS implementation of IPasteService.
/// Delegates to the existing CursorPaster, which respects user preferences for
/// AppleScript vs CGEvent paste and optional clipboard restoration.
public final class CGEventPaster: IPasteService {

    public func paste(_ text: String) {
        CursorPaster.pasteAtCursor(text)
    }
}
