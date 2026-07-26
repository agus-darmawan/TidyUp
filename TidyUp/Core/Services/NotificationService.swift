//
//  NotificationService.swift
//  TidyUp
//
//  Local-only notifications (UserNotifications) — task reminders, bill
//  reminders, and wardrobe "needs replacement / needs washing" alerts.
//

import Foundation
import UserNotifications

final class NotificationService {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleReminder(id: UUID, title: String, body: String, date: Date, repeats: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components: DateComponents = repeats
            ? Calendar.current.dateComponents([.hour, .minute], from: date)
            : Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelReminder(id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    /// Schedules a fixed-time reminder that repeats every day — used for
    /// the "don't forget to write your journal" habit nudge at 23:00.
    func scheduleDailyReminder(id: UUID, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    /// Fires "time to replace this" for linens (towels/bedsheets) once they
    /// cross their replacement interval.
    func scheduleReplacementReminder(id: UUID, itemName: String, dueDate: Date) {
        scheduleReminder(
            id: id,
            title: "Time to replace \(itemName)",
            body: "It's been a while — consider swapping this out.",
            date: dueDate
        )
    }
}
