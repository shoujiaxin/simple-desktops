//
//  WallpaperImageSource.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/2/22.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import CoreData

class WallpaperImageSource {
    public var entity = (
        name: "",
        property: (
            fullLink: "fullLink",
            name: "name",
            previewLink: "previewLink",
            timeStamp: "timeStamp"
        )
    )
    public var images: [WallpaperImage] = []

    private static var managedObjectContext: NSManagedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: Public Methods

    /// Add image to database
    /// - Parameter image: Information of the image
    public func addToDatabase(image: WallpaperImage) {
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.name, into: WallpaperImageSource.managedObjectContext)
        object.setValue(image.fullLink, forKey: entity.property.fullLink)
        object.setValue(image.name, forKey: entity.property.name)
        object.setValue(image.previewLink, forKey: entity.property.previewLink)
        object.setValue(Date(), forKey: entity.property.timeStamp)

        try? WallpaperImageSource.managedObjectContext.save()
    }

    /// Get a new image from source randomly
    public func random() -> Bool {
        preconditionFailure("random() must be overridden")
    }

    /// Remove image from array and database
    /// - Parameter index: The index of the image to be removed
    public func removeImage(at index: Int) -> WallpaperImage {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.name) = %@", images[index].name!)
        fetchRequest.fetchLimit = 1

        if let results = try? WallpaperImageSource.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject], let object = results.first {
            WallpaperImageSource.managedObjectContext.delete(object)
            try? WallpaperImageSource.managedObjectContext.save()
        }

        return images.remove(at: index)
    }

    /// Retrive all history images from database
    /// - Parameter timeAscending: The order of images by timestamp
    public func retriveFromDatabase(timeAscending: Bool) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: entity.property.timeStamp, ascending: timeAscending)]

        if let results = try? WallpaperImageSource.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
            return results
        }
        return []
    }

    // MARK: Static Methods

    /// Download the image from link to path
    /// - Parameters:
    ///   - link: Source link of the image
    ///   - path: Path to save the image
    ///   - completionHandler: Callback of completion
    public static func downloadImage(from link: String, to path: URL, completionHandler: @escaping (Error?) -> Void) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path.path) {
            DispatchQueue(label: "WallpaperImageSource.downloadImage").async {
                completionHandler(nil)
            }
            return
        }

        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: URL(string: link)!) { url, _, error in
            if let error = error {
                completionHandler(error)
                return
            }

            do {
                try fileManager.moveItem(at: url!, to: path)
            } catch {
                completionHandler(error)
                return
            }

            completionHandler(nil)
        }

        task.resume()
    }

    /// Get the image from link
    /// - Parameters:
    ///   - link: Source link of the image
    ///   - completionHandler: Callback of completion
    public static func getImage(from link: String, completionHandler: @escaping (NSImage?, Error?) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: URL(string: link)!) { data, _, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }

            completionHandler(NSImage(data: data!), nil)
        }

        task.resume()
    }
}
