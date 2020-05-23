//
//  HistoryImageManager.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/5/23.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class HistoryImageManager {
    public static var managedObjectContext: NSManagedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext

    /// Insert image to database
    /// - Parameters:
    ///   - image: Information of the image to be inserted
    ///   - entity: Information of the entity to insert the image into
    public static func insert(_ image: WallpaperImage, toEntity entity: HistoryImageEntity) {
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.name, into: managedObjectContext)
        object.setValue(image.fullLink, forKey: entity.property.fullLink)
        object.setValue(image.name, forKey: entity.property.name)
        object.setValue(image.previewLink, forKey: entity.property.previewLink)
        object.setValue(Date(), forKey: entity.property.timeStamp)

        try? managedObjectContext.save()
    }

    /// Retrieve image by full link
    /// - Parameters:
    ///   - name: Full link of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    /// - Returns: Retrieved object
    public static func retrieve(byFullLink link: String, fromEntity entity: HistoryImageEntity) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.fullLink) = %@", link)
        fetchRequest.fetchLimit = 1

        let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve image by name
    /// - Parameters:
    ///   - name: Name of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    /// - Returns: Retrieved object
    public static func retrieve(byName name: String, fromEntity entity: HistoryImageEntity) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.name) = %@", name)
        fetchRequest.fetchLimit = 1

        let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve image by preview link
    /// - Parameters:
    ///   - name: Preview link of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    /// - Returns: Retrieved object
    public static func retrieve(byPreviewLink link: String, fromEntity entity: HistoryImageEntity) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.previewLink) = %@", link)
        fetchRequest.fetchLimit = 1

        let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve all history images from database
    /// - Parameters:
    ///   - entity: Information of the entity to retrieve from
    ///   - timeAscending: The order of images by timestamp
    /// - Returns: Retrieved objects
    public static func retrieveAll(fromEntity entity: HistoryImageEntity, timeAscending: Bool) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: entity.property.timeStamp, ascending: timeAscending)]

        if let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
            return results
        }
        return []
    }
}
