import Foundation

public protocol IClipboardService: AnyObject {
    func readText() -> String?
    func writeText(_ text: String)
    /// Save current clipboard contents and return them.
    @discardableResult func save() -> String?
    /// Restore previously saved clipboard contents.
    func restore()
}
