//
//  Wallpaper.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import CoreData
import Foundation

extension Wallpaper {
    static func fetchRequest(_ predicate: NSPredicate?) -> NSFetchRequest<Wallpaper> {
        let request = NSFetchRequest<Wallpaper>(entityName: "Wallpaper")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "updateTime", ascending: false)]
        return request
    }

    static func withPreviewURL(_ url: URL, in context: NSManagedObjectContext) -> Wallpaper {
        let request = fetchRequest(NSPredicate(format: "previewURL = %@", url.absoluteString))
        if let wallpaper = try? context.fetch(request).first {
            wallpaper.updateTime = Date()
            try? context.save()
            return wallpaper
        }

        return Wallpaper(withPreviewURL: url, in: context)
    }

    convenience init(withPreviewURL url: URL, in context: NSManagedObjectContext) {
        self.init(context: context)
        // id
        id = UUID()

        // preview url
        previewURL = url

        // updateTime
        updateTime = Date()

        // url
        let lastComponent = url.lastPathComponent
        if let re = try? NSRegularExpression(pattern: #"^.+\.[a-z]{2,4}\."#, options: .caseInsensitive),
           let range = re.matches(in: lastComponent, options: .anchored, range: NSRange(location: 0, length: lastComponent.count)).first?.range
        {
            let imageName = String(lastComponent[Range(range, in: lastComponent)!].dropLast())
            self.url = url.deletingLastPathComponent().appendingPathComponent(imageName)
        }

        // name
        if let components = self.url?.pathComponents,
           let index = components.firstIndex(of: "desktops")
        {
            name = components[(index + 1)...].joined(separator: "-")
        }

        try? context.save()
    }
}
