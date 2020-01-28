//
//  ImageManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/27.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import CoreData
import Foundation
import SwiftSoup

class ImageManager {
    private struct ImageInfo {
        var previewLink: String?
        var fullLink: String? {
            guard let previewLink = previewLink else {
                return nil
            }

            let range = previewLink.range(of: ".295x184_q100.png")
            return String(previewLink[..<(range?.lowerBound)!])
        }
    }

    private var imageInfo: ImageInfo!
    private static var managedObjectContext: NSManagedObjectContext!

    init() {
        imageInfo = ImageInfo()

        let appDelegate = NSApp.delegate as! AppDelegate
        ImageManager.managedObjectContext = appDelegate.persistentContainer.viewContext
    }

    public func downloadFullImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        if let fullImageLink = imageInfo.fullLink {
            getImage(form: fullImageLink, completionHandler: handler)
        }
    }

    public func getLastPreviewImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "ImageManager.getLastPreviewImage")
        queue.async {
            // Get the latest record
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SDImage")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
            fetchRequest.fetchLimit = 1

            if let results = try? (ImageManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
                if results.count > 0 {
                    self.imageInfo.previewLink = (results[0].value(forKey: "previewLink") as! String)
                    self.getImage(form: self.imageInfo.previewLink!, completionHandler: handler)
                }
            }
        }
    }

    public func getNewPreviewImage(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "ImageManager.getNewPreviewImage")
        queue.async {
            self.newRandowImage()

            if let previewImageLink = self.imageInfo.previewLink {
                self.getImage(form: previewImageLink, completionHandler: handler)
            }
        }
    }

    private func getImage(form link: String, completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
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

    private func newRandowImage() {
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

        // Add to database
        let obj = NSEntityDescription.insertNewObject(forEntityName: "SDImage", into: ImageManager.managedObjectContext)
        obj.setValue(Date(), forKey: "timeStamp")
        obj.setValue(imageInfo.previewLink, forKey: "previewLink")
        try? ImageManager.managedObjectContext.save()
    }
}