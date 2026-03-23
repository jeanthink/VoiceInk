import Foundation

public enum ShortcutMode: Codable {
    case toggle
    case pushToTalk
    case hybrid  // short press = toggle, long hold = push-to-talk
}

public protocol IGlobalShortcut: AnyObject {
    var mode: ShortcutMode { get set }
    var onActivate: (() -> Void)? { get set }
    var onDeactivate: (() -> Void)? { get set }  // push-to-talk release

    func register() throws
    func unregister()
    var isRegistered: Bool { get }
}
