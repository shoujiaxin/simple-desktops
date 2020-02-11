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

class SimpleDesktopsSource: ImageSource {
    public class SDImageInfo: ImageInfo {
        var format: NSBitmapImageRep.FileType? {
            get {
                guard let name = name else {
                    return nil
                }

                if name.hasSuffix("png") { return .png }
                else if name.hasSuffix("jpg") { return .jpeg }
                else if name.hasSuffix("gif") { return .gif }
                else { return nil }
            }
            set {}
        }

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
    }

    override init() {
        super.init()

        entity.name = "SDImage"
        imageInfo = SDImageInfo()

        SimpleDesktopsSource.updateMaxPage()
    }

    public override func getImageInfo(from object: NSManagedObject) -> ImageInfo {
        let image = SDImageInfo()
        image.previewLink = (object.value(forKey: entity.property.previewLink) as! String)
        return image
    }

    public override func randomImage() {
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

    /// Update max page number for Simple Desktops
    private static func updateMaxPage() {
        let queue = DispatchQueue(label: "SimpleDesktopsSource.updateMaxPage")
        queue.async {
            while isSimpleDesktopsPageAvailable(page: Options.shared.simpleDesktopsMaxPage + 1) {
                Options.shared.simpleDesktopsMaxPage += 1
            }

            Options.shared.saveOptions()
        }
    }
}
