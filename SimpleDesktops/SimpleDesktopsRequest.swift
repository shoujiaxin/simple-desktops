//
//  SimpleDesktopsRequest.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/2/8.
//

import Foundation
import Logging
import SwiftSoup

struct SimpleDesktopsRequest {
    enum RequestError: Error {
        case badRequest
        case parseFailed
    }

    /// The shared singleton session object.
    static let shared: SimpleDesktopsRequest = {
        let request = SimpleDesktopsRequest(session: .shared)
        request.updateMaxPageNumber()
        return request
    }()

    /// Create an instance. It is recommended to use only in unit tests.
    /// - Parameter session: [URLSession](https://developer.apple.com/documentation/foundation/url_loading_system) used to send request.
    init(session: URLSession) {
        self.session = session
    }

    /// Fetch information about a random picture.
    /// - Returns: Picture information.
    func random() async throws -> SDPictureInfo {
        let page = Int.random(in: 1 ... maxPageNumber)
        let url = Self.baseURL.appendingPathComponent(String(page))

        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            logger.error("Bad request")
            throw RequestError.badRequest
        }

        let info = try String(data: data, encoding: .utf8)
            .map { try SwiftSoup.parse($0).select("img") }?
            .map { try $0.attr("src") }
            .randomElement()
            .flatMap(SDPictureInfo.init)

        guard let info = info else {
            throw RequestError.parseFailed
        }
        logger.info("Picture info fetched from Simple Desktops: \(String(describing: info))")

        return info
    }

    // MARK: - Private members

    /// [URLSession](https://developer.apple.com/documentation/foundation/url_loading_system) used to send request.
    private let session: URLSession

    private let logger = Logger(for: Self.self)

    /// Max page number saved in UserDefaults. If not found, use the default value.
    private var maxPageNumber: Int {
        let value = UserDefaults.standard.integer(forKey: Self.maxPageNumberKey)
        return value > 0 ? value : Self.defaultMaxPageNumber
    }

    /// Update the max page number in background task.
    private func updateMaxPageNumber() {
        let currentValue = maxPageNumber
        let url = Self.baseURL.appendingPathComponent(String(currentValue))
        Task(priority: .background) {
            do {
                let (data, _) = try await session.data(from: url)
                let numberOfImgTags = try String(data: data, encoding: .utf8)
                    .map { try SwiftSoup.parse($0).select("img") }?.count ?? 0
                if numberOfImgTags > 0 {
                    let newValue = currentValue + 1
                    UserDefaults.standard.setValue(newValue, forKey: Self.maxPageNumberKey)
                    logger.info("Max page number updated: \(newValue)")
                } else {
                    logger.info("Max page number is already up to date: \(currentValue)")
                }
            } catch {
                logger.error("Failed to update max page number, \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Constants

    private static let baseURL = URL(string: "http://simpledesktops.com/browse")!
    private static let maxPageNumberKey = "sdMaxPageNumber"
    private static let defaultMaxPageNumber = 52
}

extension SDPictureInfo {
    init?(from link: String) {
        let previewURL = URL(string: link)

        let url = previewURL.map { url -> URL in
            let lastPathComponent = url.lastPathComponent.split(separator: ".", omittingEmptySubsequences: false)[..<2].joined(separator: ".")
            return url.deletingLastPathComponent().appendingPathComponent(lastPathComponent)
        }

        let name = url?.pathComponents.split(separator: "desktops").last?.joined(separator: "-")

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
