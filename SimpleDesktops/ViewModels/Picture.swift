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
    static func retrieveFirst<Value, Key>(
        with value: Value,
        for keyPath: KeyPath<Picture, Key>,
        in context: NSManagedObjectContext
    ) -> Picture? where Value: CVarArg {
        let request = fetchRequest(
            NSPredicate(format: "%K == %@", NSExpression(forKeyPath: keyPath).keyPath, value),
            fetchLimit: 1
        )
        return try? context.fetch(request).first
    }

    /// Update an existing picture, or create one with the given SDPictureInfo if it does not exist. The url of the picture is used as the key for database queries.
    /// - Parameters:
    ///   - info: Information of the picture.
    ///   - context: Managed object context of the persistent container.
    /// - Returns: The updated object.
    @discardableResult
    static func update(with info: SDPictureInfo, in context: NSManagedObjectContext) -> Picture {
        let picture = retrieveFirst(with: info.url.absoluteString, for: \.url_, in: context) ??
            Picture(context: context)

        if picture.id_ == nil {
            picture.id_ = UUID()
            picture.url_ = info.url
        }
        picture.lastFetchedTime = Date()
        picture.name = info.name
        picture.previewURL = info.previewURL

        try? context.save()
        return picture
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
