import Foundation
import UserNotifications

struct NotificationService {
    func requestAuthorization() async {
        guard canUseUserNotifications else { return }
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    func sendOperationFinished(savedBytes: Int64) async {
        guard canUseUserNotifications else { return }
        let content = UNMutableNotificationContent()
        content.title = "Silica finished compressing"
        content.body = "Saved \(ByteCountFormatter.silica.string(fromByteCount: savedBytes))"
        content.sound = .default
        await send(content)
    }

    func sendError(title: String, body: String) async {
        guard canUseUserNotifications else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        await send(content)
    }

    private func send(_ content: UNNotificationContent) async {
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }

    private var canUseUserNotifications: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }
}
