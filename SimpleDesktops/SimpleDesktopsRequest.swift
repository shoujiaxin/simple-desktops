//
//  SimpleDesktopsRequest.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/8.
//

import Combine
import CoreData
import SwiftSoup

struct SDPictureInfo {
    let name: String

    let previewURL: URL

    let url: URL

    init?(name: String?, previewURL: URL?, url: URL?) {
        guard let name = name,
              let previewURL = previewURL,
              let url = url
        else {
            return nil
        }

        self.name = name
        self.previewURL = previewURL
        self.url = url
    }
}

enum SimpleDesktopsRequest {
    static func randomPicture() -> Future<SDPictureInfo, Error> {
        Future { promise in
            let page = Int.random(in: 1 ... maxPageNumber)
            let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                do {
                    let info = try data
                        .flatMap { String(data: $0, encoding: .utf8) }
                        .map { try SwiftSoup.parse($0) }?.select("img")
                        .map { try $0.attr("src") }
                        .randomElement()
                        .flatMap { parsePictureInfo(from: $0) }

                    if let info = info {
                        promise(.success(info))
                    } else {
                        // TODO: Throw an error
                    }
                } catch {
                    promise(.failure(error))
                }
            }.resume()
        }
    }

    // MARK: - Private Members

    private static var maxPageNumber: Int = {
        // Get old value from UserDefaults
        var defaultValue = UserDefaults.standard.integer(forKey: MAX_PAGE_NUMBER_KEY)
        defaultValue = defaultValue > 0 ? defaultValue : 52

        // Update value
        // TODO: Force update value manually
        let url = URL(string: "http://simpledesktops.com/browse/\(defaultValue)/")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            data
                .flatMap { String(data: $0, encoding: .utf8) }
                .flatMap { try? SwiftSoup.parse($0).select("img") }
                .map { elements in
                    if elements.count > 0 {
                        UserDefaults.standard.setValue(defaultValue + 1, forKey: MAX_PAGE_NUMBER_KEY)
                    }
                }
        }.resume()

        return defaultValue
    }()

    private static func parsePictureInfo(from link: String) -> SDPictureInfo? {
        let previewURL = URL(string: link)

        let url = previewURL.map { url -> URL in
            let lastPathComponent = url.lastPathComponent.split(separator: ".")[..<2].joined(separator: ".")
            return url.deletingLastPathComponent().appendingPathComponent(lastPathComponent)
        }

        let name = url?.pathComponents.split(separator: "desktops").last?.joined(separator: "-")

        return SDPictureInfo(name: name, previewURL: previewURL, url: url)
    }

    // MARK: - Constants

    private static let MAX_PAGE_NUMBER_KEY = "sdMaxPageNumber"
}

extension Picture {
    @discardableResult
    static func update(from info: SDPictureInfo, in context: NSManagedObjectContext) -> Picture {
        let picture = withURL(info.url, in: context)
        if picture.id_ == nil {
            picture.id_ = UUID()
        }
        picture.lastFetchedTime = Date()
        picture.name = info.name
        picture.previewURL = info.previewURL

        try? context.save()

        return picture
    }
}
