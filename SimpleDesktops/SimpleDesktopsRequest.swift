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

class SimpleDesktopsRequest {
    static let shared = SimpleDesktopsRequest()

    var randomPicturePublisher: AnyPublisher<SDPictureInfo?, URLError> {
        let page = Int.random(in: 1 ... maxPageNumber)
        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, _) -> SDPictureInfo? in
                do {
                    let links = try String(data: data, encoding: .utf8)
                        .map { try SwiftSoup.parse($0) }?.select("img")
                        .map { try $0.attr("src") }
                    return self.parse(from: links?.randomElement())
                } catch {
                    // TODO: log
                    print(error.localizedDescription)
                }

                return nil
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: Private Members

    private var maxPageNumber: Int {
        get {
            let oldValue = UserDefaults.standard.integer(forKey: "sdMaxPageNumber")
            return oldValue > 0 ? oldValue : 52
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "sdMaxPageNumber")
        }
    }

    private init() {
        updateMaxPageNumber()
    }

    private func updateMaxPageNumber() {
        let url = URL(string: "http://simpledesktops.com/browse/\(maxPageNumber)/")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let imgTag = data.flatMap({ String(data: $0, encoding: .utf8) }).flatMap({ try? SwiftSoup.parse($0).select("img") }),
               imgTag.count > 0
            {
                self.maxPageNumber += 1
            }
        }.resume()
    }

    private func parse(from link: String?) -> SDPictureInfo? {
        let previewURL = link.flatMap { URL(string: $0) }

        let url = previewURL.map { url -> URL in
            let lastPathComponent = url.lastPathComponent.split(separator: ".")[..<2].joined(separator: ".")
            return url.deletingLastPathComponent().appendingPathComponent(lastPathComponent)
        }

        let name = url?.pathComponents.split(separator: "desktops").last?.joined(separator: "-")

        return SDPictureInfo(name: name, previewURL: previewURL, url: url)
    }
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
