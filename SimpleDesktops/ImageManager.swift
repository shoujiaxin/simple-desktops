//
//  ImageManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/27.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Foundation
import SwiftSoup

class ImageManager {
    private struct Image {
        var previewLink: String?
        var fullLink: String? {
            guard let previewLink = previewLink else {
                return nil
            }

            let range = previewLink.range(of: ".295x184_q100.png")
            return String(previewLink[..<(range?.lowerBound)!])
        }
    }

    private var currentImage: Image!

    public var isPreviewImageLoading: Bool = false
    public var isFullImageDownloading: Bool = false

    init() {
        currentImage = Image()
    }

    public func getPreviewImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "ImageManager.getPreviewImage")
        queue.async {
            self.isPreviewImageLoading = true

            var imageLink = self.getRandomImageLink()
            while self.isImageLoaded(from: imageLink) {
                imageLink = self.getRandomImageLink()
            }

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: URL(string: imageLink)!) { data, _, error in
                self.isPreviewImageLoading = false

                if let error = error {
                    handler(nil, error)
                    return
                }

                self.currentImage.previewLink = imageLink
                handler(NSImage(data: data!), nil)
            }

            task.resume()
        }
    }

    public func downloadFullImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "ImageManager.downloadFullImage")
        queue.async {
            guard let fullImageLink = self.currentImage.fullLink else {
                return
            }

            self.isFullImageDownloading = true

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: URL(string: fullImageLink)!) { _, _, error in
                self.isFullImageDownloading = false

                if let error = error {
                    handler(nil, error)
                    return
                }

                handler(nil, nil)
            }

            task.resume()
        }
    }

    private func getImageLinks(onPage page: Int) -> [String] {
        let semaphore = DispatchSemaphore(value: 0)

        var linkList: [String] = []

        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                semaphore.signal()
                return
            }

            do {
                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)
                let imgTags: Elements = try doc.select("img")

                for tag in imgTags {
                    try linkList.append(tag.attr("src"))
                }

                semaphore.signal()
            } catch {
                semaphore.signal()
                return
            }
        }

        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return linkList
    }

    private func getRandomImageLink() -> String {
        let page = Int.random(in: 1 ... Options.shared.simpleDesktopsMaxPage)
        let linkList = getImageLinks(onPage: page)
        return linkList[Int.random(in: 1 ..< linkList.count)]
    }

    private func isImageLoaded(from _: String) -> Bool {
        return false
    }
}
