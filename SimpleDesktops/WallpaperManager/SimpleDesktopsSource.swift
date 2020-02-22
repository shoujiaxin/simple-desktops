//
//  SimpleDesktopsSource.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/30.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import SwiftSoup

class SimpleDesktopsSource: WallpaperImageSource {
    public class SDImage: WallpaperImage {
        var fullLink: String? {
            get {
                guard let previewLink = previewLink else {
                    return nil
                }

                let range = previewLink.range(of: ".295x184_q100.png")
                return String(previewLink[..<(range?.lowerBound)!])
            }
            set {}
        }

        var name: String? {
            get {
                guard let fullLink = fullLink else {
                    return nil
                }

                let range = fullLink.range(of: "desktops/")
                return String(fullLink[(range?.upperBound...)!]).replacingOccurrences(of: "/", with: "-")
            }
            set {}
        }

        var previewLink: String?

        func download(to path: URL, completionHandler: @escaping (Error?) -> Void) {
            if let link = fullLink {
                WallpaperImageSource.downloadImage(from: link, to: path, completionHandler: completionHandler)
            }
        }

        func fullImage(completionHandler: @escaping (NSImage?, Error?) -> Void) {
            if let link = fullLink {
                WallpaperImageSource.getImage(from: link, completionHandler: completionHandler)
            }
        }

        func previewImage(completionHandler: @escaping (NSImage?, Error?) -> Void) {
            if let link = previewLink {
                WallpaperImageSource.getImage(from: link, completionHandler: completionHandler)
            }
        }
    }

    override init() {
        super.init()

        entity.name = "SDImage"

        // Load history images to array
        for object in retriveFromDatabase(timeAscending: false) {
            if let previewLink = object.value(forKey: entity.property.previewLink) as? String {
                let image = SDImage()
                image.previewLink = previewLink
                images.append(image)
            }
        }

        SimpleDesktopsSource.updateMaxPage()
    }

    override func random() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)

        var links: [String] = []
        var success = false

        let page = Int.random(in: 1 ... Options.shared.simpleDesktopsMaxPage)
        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                semaphore.signal()
                return
            }

            if let doc = try? SwiftSoup.parse(String(data: data!, encoding: .utf8)!), let imgTags = try? doc.select("img") {
                for tag in imgTags {
                    try? links.append(tag.attr("src"))
                }
            }

            while !links.isEmpty {
                let index = Int.random(in: links.startIndex ..< links.endIndex)
                let image = SDImage()
                image.previewLink = links[index]

                // Check if duplicate
                if self.images.contains(where: { $0.name == image.name }) {
                    links.remove(at: index)
                } else {
                    self.images.insert(image, at: self.images.startIndex)
                    self.addToDatabase(image: image)

                    success = true
                    break
                }
            }

            semaphore.signal()
        }

        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)

        return success
    }

    // MARK: Private Methods

    /// Return true if the page contains images
    /// - Parameter page: Number of the page to be checked
    private static func isPageAvailable(page: Int) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)

        var isAvailable = false

        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                semaphore.signal()
                return
            }

            if let doc = try? SwiftSoup.parse(String(data: data!, encoding: .utf8)!), let imgTags = try? doc.select("img"), imgTags.count > 0 {
                isAvailable = true
            }

            semaphore.signal()
        }

        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)

        return isAvailable
    }

    /// Update max page number for Simple Desktops
    private static func updateMaxPage() {
        let queue = DispatchQueue(label: "SimpleDesktopsSource.updateMaxPage")
        queue.async {
            while isPageAvailable(page: Options.shared.simpleDesktopsMaxPage + 1) {
                Options.shared.simpleDesktopsMaxPage += 1
            }

            Options.shared.saveOptions()
        }
    }
}
