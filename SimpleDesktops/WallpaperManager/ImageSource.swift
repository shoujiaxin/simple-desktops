//
//  ImageSource.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/2/5.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import CoreData

protocol ImageInfo {
    var format: NSBitmapImageRep.FileType? { get set }

    var fullLink: String? { get set }

    var name: String? { get set }

    var previewLink: String? { get set }
}

class ImageSource {
    public var entity = (
        name: "",
        property: (
            fullLink: "fullLink",
            name: "name",
            previewLink: "previewLink",
            timeStamp: "timeStamp"
        )
    )
    public var imageInfo: ImageInfo!

    /// Get full image from URL
    /// - Parameter handler: Callback of completion
    public func getFullImage(completionHandler handler: @escaping (NSImage?, Error?) -> Void) {
        if let fullImageLink = imageInfo.fullLink {
            getImage(form: fullImageLink, completionHandler: handler)
        }
    }

    /// Get image frome URL
    /// - Parameters:
    ///   - link: Source link of the image
    ///   - handler: Callback of completion
    public func getImage(form link: String, completionHandler handler: @escaping (NSImage?, Error?) -> Void) {
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

    /// Get image info from database object
    /// - Parameter object: Database object
    public func getImageInfo(from _: NSManagedObject) -> ImageInfo {
        fatalError("ImageSource.getImageInfo must override")
    }

    /// Get preview image from URL
    /// - Parameter handler: Callback of completion
    public func getPreviewImage(completionHandler handler: @escaping (NSImage?, Error?) -> Void) {
        if let previewImageLink = imageInfo.previewLink {
            getImage(form: previewImageLink, completionHandler: handler)
        }
    }

    /// Get an image from source randomly, must override
    public func randomImage() -> Bool {
        fatalError("ImageSource.randomImage must override")
    }
}
