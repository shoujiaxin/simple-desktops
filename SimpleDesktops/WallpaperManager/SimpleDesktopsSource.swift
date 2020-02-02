//
//  SimpleDesktopsSource.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/30.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import CoreData
import Foundation
import SwiftSoup

class SimpleDesktopsSource {
    public struct ImageInfo {
        init() {}

        init(withPreviewLink link: String) {
            previewLink = link
        }

        var fullLink: String? {
            guard let previewLink = previewLink else {
                return nil
            }

            let range = previewLink.range(of: ".295x184_q100.png")
            return String(previewLink[..<(range?.lowerBound)!])
        }

        var name: String? {
            guard let fullLink = fullLink else {
                return nil
            }

            let range = fullLink.range(of: "desktops/")
            return String(fullLink[(range?.upperBound...)!]).replacingOccurrences(of: "/", with: "-")
        }

        var previewLink: String?
    }

    public var imageInfo = ImageInfo()

    public func getFullImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        if let fullImageLink = imageInfo.fullLink {
            getImage(form: fullImageLink, completionHandler: handler)
        }
    }

    /// Get image frome URL
    /// - Parameters:
    ///   - link: Source link of the image
    ///   - handler: Callback of completion
    public func getImage(form link: String, completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: URL(string: link)!) { data, _, error in
            if let error = error {
                handler(nil, error)
                return
            }

            handler(NSImage(data: data!), nil)
        }

        task.resume()
    }

    public func getPreviewImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        if let previewImageLink = imageInfo.previewLink {
            getImage(form: previewImageLink, completionHandler: handler)
        }
    }

    /// Get an image randomly from Simple Desktops
    public func randomImage() {
        let semaphore = DispatchSemaphore(value: 0)

        var linkList: [String] = []

        let page = Int.random(in: 1 ... Options.shared.simpleDesktopsMaxPage)
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

        imageInfo.previewLink = linkList[Int.random(in: 1 ..< linkList.count)]
    }

    public static func updateSimpleDesktopsMaxPage() {
        let queue = DispatchQueue(label: "Utils.updateSimpleDesktopsMaxPage")
        queue.async {
            while isSimpleDesktopsPageAvailable(page: Options.shared.simpleDesktopsMaxPage + 1) {
                Options.shared.simpleDesktopsMaxPage += 1
            }

            Options.shared.saveOptions()
        }
    }

    /// Return true if the page contains images
    /// - Parameter page: Number of the page to be checked
    private static func isSimpleDesktopsPageAvailable(page: Int) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)

        var isAvailable = false

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

                if imgTags.count > 0 {
                    isAvailable = true
                }
                semaphore.signal()
            } catch {
                semaphore.signal()
                return
            }
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)

        return isAvailable
    }
}
