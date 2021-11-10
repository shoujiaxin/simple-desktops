//
//  Picture.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/2/7.
//

import CoreData

extension Picture {
    /// Construct a description of search criteria used to retrieve pictures from Core Data.
    /// - Parameters:
    ///   - predicate: The predicate of the fetch request.
    ///   - fetchLimit: The fetch limit of the fetch request.
    /// - Returns: An instance of [NSFetchRequest](https://developer.apple.com/documentation/coredata/nsfetchrequest).
    static func fetchRequest(_ predicate: NSPredicate?,
                             fetchLimit: Int = 0) -> NSFetchRequest<Picture> {
        let request = fetchRequest()
        request.predicate = predicate
        request
            .sortDescriptors =
            [NSSortDescriptor(keyPath: \Picture.lastFetchedTime_, ascending: false)]
        request.fetchLimit = fetchLimit
        return request
    }

    /// Retrieve the first matched picture with the specified value of the key path.
    /// - Returns: Retrieved object or `nil` if it does not exist.
    static func retrieveFirst<Key>(with value: CVarArg, for keyPath: KeyPath<Picture, Key>,
                                   in context: NSManagedObjectContext) -> Picture? {
        let request = fetchRequest(
            NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, value),
            fetchLimit: 1
        )
        return try? context.fetch(request).first
    }

    /// Update the picture with the given SDPictureInfo.
    /// - Parameter info: Information of the picture.
    func update(with info: SDPictureInfo) {
        if id_ == nil {
            id_ = UUID()
            url_ = info.url
        }
        lastFetchedTime = Date()
        name = info.name
        previewURL = info.previewURL

        try? managedObjectContext?.save()
    }

    // MARK: - Wrappers for none-optional properties

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
