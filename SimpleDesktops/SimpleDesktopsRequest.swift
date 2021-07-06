//
//  SimpleDesktopsRequest.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/8.
//

import Combine
import CoreData
import SwiftSoup

// MARK: -

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

// MARK: -

enum SimpleDesktopsError: Error {
    case badRequest
    case soupFailed
}

// MARK: -

struct SimpleDesktopsRequest {
    static let shared: SimpleDesktopsRequest = {
        let request = SimpleDesktopsRequest(session: .shared)
        request.updateMaxPageNumber()
        return request
    }()

    init(session: URLSession) {
        self.session = session
    }

    var randomPicture: Future<SDPictureInfo, Error> {
        Future { promise in
            let page = Int.random(in: 1 ... maxPageNumber)
            let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
            session.dataTask(with: url) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let response = response as? HTTPURLResponse,
                      200 ..< 300 ~= response.statusCode
                else {
                    promise(.failure(SimpleDesktopsError.badRequest))
                    return
                }

                do {
                    try data
                        .flatMap { String(data: $0, encoding: .utf8) }
                        .flatMap { try SwiftSoup.parse($0) }?.select("img")
                        .compactMap { try $0.attr("src") }
                        .randomElement()
                        .flatMap { parsePictureInfo(from: $0) }
                        .map { promise(.success($0)) }
                } catch {
                    promise(.failure(SimpleDesktopsError.soupFailed))
                }
            }.resume()
        }
    }

    func updateMaxPageNumber() {
        // TODO: Update manually
        let url = URL(string: "http://simpledesktops.com/browse/\(maxPageNumber)/")!
        session.dataTask(with: url) { data, _, _ in
            data
                .flatMap { String(data: $0, encoding: .utf8) }
                .flatMap { try? SwiftSoup.parse($0).select("img") }
                .map { elements in
                    if elements.count > 0 {
                        UserDefaults.standard.setValue(maxPageNumber + 1, forKey: Self.MAX_PAGE_NUMBER_KEY)
                    }
                }
        }.resume()
    }

    // MARK: - Private members

    private let session: URLSession

    private var maxPageNumber: Int {
        let value = UserDefaults.standard.integer(forKey: Self.MAX_PAGE_NUMBER_KEY)
        return value > 0 ? value : Self.DEFAULT_MAX_PAGE
    }

    private func parsePictureInfo(from link: String) -> SDPictureInfo? {
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
    private static let DEFAULT_MAX_PAGE = 52
}

// MARK: -

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
