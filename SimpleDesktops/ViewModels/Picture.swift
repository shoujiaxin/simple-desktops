//
//  Picture.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/7.
//

import CoreData

extension Picture {
    static func fetchRequest(_ predicate: NSPredicate?, fetchLimit: Int = 0) -> NSFetchRequest<Picture> {
        let request = NSFetchRequest<Picture>(entityName: "Picture")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "lastFetchedTime_", ascending: false)]
        request.fetchLimit = fetchLimit
        return request
    }

    static func withURL(_ url: URL, in context: NSManagedObjectContext) -> Picture {
        let request = fetchRequest(NSPredicate(format: "url_ = %@", url.absoluteString))
        if let picture = try? context.fetch(request).first {
            return picture
        } else {
            let picture = Picture(context: context)
            picture.url = url
            return picture
        }
    }

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

    // MARK: - Wrappers For None-Optional Values

    public var id: UUID {
        get { id_! }
        set { id_ = newValue }
    }

    var lastFetchedTime: Date {
        get { lastFetchedTime_! }
        set { lastFetchedTime_ = newValue }
    }

    var url: URL {
        get { url_! }
        set { url_ = newValue }
    }
}
