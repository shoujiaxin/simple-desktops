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
        if let object = retrieveFromDatabase(at: index) {
            WallpaperImageSource.managedObjectContext.delete(object)
            try? WallpaperImageSource.managedObjectContext.save()
        }

        return images.remove(at: index)
    }

    /// Retrieve the object of images[index] from database
    /// - Parameter index: The index of the image to be retrieved
    /// - Returns: NSManagedObject of the image
    public func retrieveFromDatabase(at index: Int) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.name) = %@", images[index].name!)
        fetchRequest.fetchLimit = 1

        let results = try? WallpaperImageSource.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve all history images from database
    /// - Parameter timeAscending: The order of images by timestamp
    public func retrieveAllFromDatabase(timeAscending: Bool) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: entity.property.timeStamp, ascending: timeAscending)]

        if let results = try? WallpaperImageSource.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
            return results
        }
        return []
    }
}
