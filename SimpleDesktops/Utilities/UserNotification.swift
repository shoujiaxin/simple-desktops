//
//  UserNotification.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/23.
//

import UserNotifications

struct UserNotification {
    static let shared = UserNotification()

    func request(title: String, body: String, attachmentURLs: [URL?] = []) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.attachments = attachmentURLs.compactMap { url -> UNNotificationAttachment? in
            guard let url = url else {
                return nil
            }

            // Copy attachment files to temporary directory
            let attachmentURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            try? Data(contentsOf: url).write(to: attachmentURL)
            return try? .init(identifier: url.lastPathComponent, url: attachmentURL, options: nil)
        }

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // TODO: Log
                print(error.localizedDescription)
            }
        }
    }

    private init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, error in
            if let error = error {
                // TODO: Log
                print(error.localizedDescription)
            }
        }
    }
}
