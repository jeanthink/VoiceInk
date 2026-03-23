import AppKit

/// macOS implementation of IClipboardService using NSPasteboard.
/// Wraps the existing ClipboardManager static helpers and preserves the
/// transient-type and bundle-source metadata that NSPasteboard-aware apps use.
public final class NSPasteboardClipboard: IClipboardService {

    // Multi-type snapshot taken by save(), restored by restore().
    private var savedItems: [(NSPasteboard.PasteboardType, Data)] = []

    public func readText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }

    public func writeText(_ text: String) {
        ClipboardManager.setClipboard(text, transient: false)
    }

    @discardableResult
    public func save() -> String? {
        let pasteboard = NSPasteboard.general
        savedItems = (pasteboard.pasteboardItems ?? []).flatMap { item in
            item.types.compactMap { type in
                item.data(forType: type).map { (type, $0) }
            }
        }
        return pasteboard.string(forType: .string)
    }

    public func restore() {
        guard !savedItems.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        for (type, data) in savedItems {
            pasteboard.setData(data, forType: type)
        }
        savedItems = []
    }
}
