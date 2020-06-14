//
//  HistoryImageManager.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/5/23.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class HistoryImageManager {
    // Singleton pattern
    public static let shared = HistoryImageManager()

    private let managedObjectContext: NSManagedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    private var cacheObjects: [NSManagedObject] = []

    /// Insert image to database
    /// - Parameters:
    ///   - image: Information of the image to be inserted
    ///   - entity: Information of the entity to insert the image into
    public func insert(_ image: WallpaperImage, toEntity entity: HistoryImageEntity) {
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.name, into: managedObjectContext)
        object.setValue(image.fullUrl, forKey: entity.property.fullUrl)
        object.setValue(image.name, forKey: entity.property.name)
        object.setValue(image.previewUrl, forKey: entity.property.previewUrl)
        object.setValue(Date(), forKey: entity.property.timeStamp)

//        try? managedObjectContext.save()
    }

    /// Delete image by name
    /// - Parameters:
    ///   - name: Name of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    public func delete(byName name: String, fromEntity entity: HistoryImageEntity) {
        if let object = retrieve(byName: name, fromEntity: entity) {
            managedObjectContext.delete(object)
//            try? managedObjectContext.save()
        }
    }

    /// Retrieve image by full link
    /// - Parameters:
    ///   - link: Full link of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    /// - Returns: Retrieved object
    public func retrieve(byFullLink link: String, fromEntity entity: HistoryImageEntity) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.fullUrl) = %@", link)
        fetchRequest.fetchLimit = 1

        let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve image by name
    /// - Parameters:
    ///   - name: Name of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    /// - Returns: Retrieved object
    public func retrieve(byName name: String, fromEntity entity: HistoryImageEntity) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.name) = %@", name)
        fetchRequest.fetchLimit = 1

        let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve image by preview link
    /// - Parameters:
    ///   - link: Preview link of the image to be retrieved
    ///   - entity: Information of the entity to retrieve from
    /// - Returns: Retrieved object
    public func retrieve(byPreviewLink link: String, fromEntity entity: HistoryImageEntity) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(entity.property.previewUrl) = %@", link)
        fetchRequest.fetchLimit = 1

        let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        return results?.first
    }

    /// Retrieve all history images from database
    /// - Parameters:
    ///   - entity: Information of the entity to retrieve from
    ///   - timeAscending: The order of images by timestamp
    /// - Returns: Retrieved objects
    public func retrieveAll(fromEntity entity: HistoryImageEntity, timeAscending: Bool) -> [NSManagedObject] {
        if !cacheObjects.isEmpty, !managedObjectContext.hasChanges {
            return cacheObjects
        }

        try? managedObjectContext.save()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: entity.property.timeStamp, ascending: timeAscending)]

        if let results = try? managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
            cacheObjects = results
            return results
        }
        return []
    }
}
