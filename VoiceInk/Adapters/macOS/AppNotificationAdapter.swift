import AppKit

/// macOS implementation of INotificationService.
/// Delegates to the existing in-app NotificationManager (NSPanel overlay),
/// which also handles error sounds and dismiss timers.
@MainActor
public final class AppNotificationAdapter: INotificationService {

    public func show(title: String, kind: NotificationKind) {
        let type: AppNotificationView.NotificationType = kind == .error ? .error : .info
        NotificationManager.shared.showNotification(title: title, type: type)
    }
}
