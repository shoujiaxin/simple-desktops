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
        var fullUrl: URL? {
            get {
                guard let lastComponent = previewUrl?.lastPathComponent,
                    let re = try? NSRegularExpression(pattern: #"^.+\.[a-z]{2,4}\."#, options: .caseInsensitive),
                    let range = re.matches(in: lastComponent, options: .anchored, range: NSRange(location: 0, length: lastComponent.count)).first?.range
                else {
                    return nil
                }

                let imageName = String(lastComponent[Range(range, in: lastComponent)!].dropLast())
                return previewUrl?.deletingLastPathComponent().appendingPathComponent(imageName)
            }
            set {}
        }

        var name: String? {
            get {
                guard let components = fullUrl?.pathComponents,
                    let index = components.firstIndex(of: "desktops")
                else {
                    return nil
                }

                return components[(index + 1)...].joined(separator: "-")
            }
            set {}
        }

        var previewUrl: URL?
    }

    public let entity = HistoryImageEntity(name: "SDImage")

    public var images: [WallpaperImage] {
        // Load history images to array
        var arr: [WallpaperImage] = []
        for object in HistoryImageManager.shared.retrieveAll(fromEntity: entity, timeAscending: false) {
            if let url = object.value(forKey: entity.property.previewUrl) as? URL {
                let image = SDImage()
                image.previewUrl = url
                arr.append(image)
            }
        }
        return arr
    }

    init() {
        SimpleDesktopsSource.updateMaxPage()
    }

    public func removeImage(at index: Int) {
        if let imageName = images[index].name {
            HistoryImageManager.shared.delete(byName: imageName, fromEntity: entity)
        }
    }

    public func updateImage() -> WallpaperImage? {
        let semaphore = DispatchSemaphore(value: 0)

        var links: [String] = []
        var image: SDImage?

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

            if let link = links.randomElement() {
                image = SDImage()
                image!.previewUrl = URL(string: link)

                // The image is already loaded, remove it first to avoid duplicates
                HistoryImageManager.shared.delete(byName: image!.name!, fromEntity: self.entity)
                HistoryImageManager.shared.insert(image!, toEntity: self.entity)
            }

            semaphore.signal()
        }

        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)

        return image
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
