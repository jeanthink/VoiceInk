import Foundation

public enum NotificationKind {
    case info
    case error
}

public protocol INotificationService: AnyObject {
    /// Show a transient in-app or system notification.
    func show(title: String, kind: NotificationKind)
}
