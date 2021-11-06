//
//  UserNotification.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/2/23.
//

import Kingfisher
import UserNotifications

struct UserNotification {
    static func request(title: String, body: String, attachmentURLs: [URL?] = []) async throws {
        // Request authorization
        guard try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.attachments = try attachmentURLs.compactMap { url in
            guard let url = url else {
                return nil
            }

            // Copy attachment files to temporary directory
            let attachmentURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(url.lastPathComponent)

            // Retrieve image data from cache
            KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString) { result in
                if case let .success(imageResult) = result {
                    try? imageResult.image?.tiffRepresentation?.write(to: attachmentURL)
                }
            }

            return try UNNotificationAttachment(
                identifier: url.lastPathComponent,
                url: attachmentURL,
                options: nil
            )
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try await UNUserNotificationCenter.current().add(request)
    }
}
