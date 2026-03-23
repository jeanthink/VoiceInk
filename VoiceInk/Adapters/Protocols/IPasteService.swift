import Foundation

public protocol IPasteService: AnyObject {
    /// Paste text at the current cursor position using platform keyboard simulation.
    func paste(_ text: String)
}
