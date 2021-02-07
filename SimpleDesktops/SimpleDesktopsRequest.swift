//
//  SimpleDesktopsRequest.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/8.
//

import Combine
import Foundation
import SwiftSoup

struct SDPictureInfo {
    let name: String

    let previewURL: URL

    let url: URL
}

class SimpleDesktopsRequest {
    static let shared = SimpleDesktopsRequest()

    var randomPicturePublisher: AnyPublisher<SDPictureInfo?, URLError> {
        var links: [String] = []
        let page = Int.random(in: 1 ... maxPageNumber)
        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, _) -> SDPictureInfo? in
                guard let html = String(data: data, encoding: .utf8) else {
                    return nil
                }

                do {
                    let imgTags = try SwiftSoup.parse(html).select("img")
                    try imgTags.forEach { tag in
                        links.append(try tag.attr("src"))
                    }
                } catch {
                    print(error)
                }

                return self.parse(from: links.randomElement())
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: Private Members

    private var maxPageNumber: Int = UserDefaults.standard.integer(forKey: "sdMaxPageNumber") {
        willSet {
            UserDefaults.standard.setValue(newValue, forKey: "sdMaxPageNumber")
        }
    }

    private init() {
        updateMaxPageNumber()
    }

    private func updateMaxPageNumber() {
        let page = max(maxPageNumber, 53)
        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let html = String(data: data, encoding: .utf8),
               let document = try? SwiftSoup.parse(html),
               let imgTag = try? document.select("img"),
               imgTag.count > 0
            {
                self.maxPageNumber = page + 1
            }
        }.resume()
    }

    private func parse(from link: String?) -> SDPictureInfo? {
        guard let link = link,
              let previewURL = URL(string: link)
        else {
            return nil
        }

        let lastPathComponent = previewURL.lastPathComponent
        let re = try! NSRegularExpression(pattern: #"^.+\.[a-z]{2,4}\."#, options: .caseInsensitive)
        guard let range = re.matches(in: lastPathComponent, options: .anchored, range: NSRange(location: 0, length: lastPathComponent.count)).first?.range else {
            return nil
        }
        let url = previewURL
            .deletingLastPathComponent()
            .appendingPathComponent(String(lastPathComponent[Range(range, in: lastPathComponent)!].dropLast()))

        let components = url.pathComponents
        guard let index = components.firstIndex(of: "desktops") else {
            return nil
        }
        let name = components[(index + 1)...].joined(separator: "-")

        return SDPictureInfo(name: name, previewURL: previewURL, url: url)
    }
}
