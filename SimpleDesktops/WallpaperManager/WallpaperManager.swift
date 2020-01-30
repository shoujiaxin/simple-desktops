//
//  WallpaperManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/30.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import CoreData

class WallpaperManager {
    private var source = SimpleDesktopsSource()
    private static var managedObjectContext: NSManagedObjectContext!

    init() {
        let appDelegate = NSApp.delegate as! AppDelegate
        WallpaperManager.managedObjectContext = appDelegate.persistentContainer.viewContext
    }

    /// Download image to hard disk
    /// - Parameters:
    ///   - url: URL of the image
    ///   - handler: Callback of completion
    public func downloadWallpaper(to url: URL, completionHandler handler: @escaping (_ error: Error?) -> Void) {
        source.getFullImage { image, error in
            if let error = error {
                handler(error)
                return
            }

            do {
                try image?.writePng(to: url)
                handler(nil)
            } catch {
                handler(error)
                return
            }
        }
    }

    public func getLastWallpaper(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.getLastWallpaper")
        queue.async {
            // Get the latest record
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SDImage")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
            fetchRequest.fetchLimit = 1

            if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
                if results.count > 0 {
                    // Found history from database
                    self.source.imageInfo.previewLink = (results[0].value(forKey: "previewLink") as! String)
                    self.source.getPreviewImage(completionHandler: handler)
                } else {
                    // Run the app for the first time, get a new image
                    self.updatePreview(completionHandler: handler)
                }
            }
        }
    }

    /// Set wallpaper for all workspaces (desktops) on all screens
    /// - Parameter handler: Callback of completion
    public func setWallpaper(completionHandler handler: @escaping (_ error: Error?) -> Void) {
        // Save the image to ~/Library/Containers/me.jiaxin.SimpleDesktops/Data/Library/Application Support/SimpleDesktops/Wallpaper/
        let wallpaperDirectory = "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])/\((Bundle.main.infoDictionary!["CFBundleName"])!)/Wallpaper/"

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: wallpaperDirectory) {
            // Clear old wallpapers
            if let files = try? fileManager.contentsOfDirectory(atPath: wallpaperDirectory) {
                for file in files {
                    do {
                        try fileManager.trashItem(at: URL(fileURLWithPath: wallpaperDirectory + "/\(file)"), resultingItemURL: nil)
                    } catch {
                        handler(error)
                        return
                    }
                }
            }
        } else {
            // Create the folder if it not exists
            do {
                try fileManager.createDirectory(atPath: wallpaperDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                handler(error)
                return
            }
        }

        let url = URL(fileURLWithPath: "\(wallpaperDirectory)/\((source.imageInfo.name)!)")
        downloadWallpaper(to: url) { error in
            if let error = error {
                handler(error)
                return
            }

            self.setWallpaperForAllScreens(with: url)
            NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { _ in
                self.setWallpaperForAllScreens(with: url)
            }
            handler(nil)
        }
    }

    /// Update preview image randomly
    /// - Parameter handler: Callback of completion
    public func updatePreview(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.updatePreview")
        queue.async {
            self.source.randomImage()

            // Add to database
            let obj = NSEntityDescription.insertNewObject(forEntityName: "SDImage", into: WallpaperManager.managedObjectContext)
            obj.setValue(self.source.imageInfo.name, forKey: "name")
            obj.setValue(self.source.imageInfo.previewLink, forKey: "previewLink")
            obj.setValue(Date(), forKey: "timeStamp")

            do {
                try WallpaperManager.managedObjectContext.save()
            } catch {
                handler(nil, error)
                return
            }

            self.source.getPreviewImage(completionHandler: handler)
        }
    }

    private func setWallpaperForAllScreens(with url: URL) {
        let screens = NSScreen.screens
        for screen in screens {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }
    }
}

private extension NSImage {
    func writePng(to url: URL, options: Data.WritingOptions = .atomic) throws {
        guard let tiffRepresentation = tiffRepresentation,
            let bitmapImageRep = NSBitmapImageRep(data: tiffRepresentation),
            let data = bitmapImageRep.representation(using: .png, properties: [:]) else {
            return
        }

        do {
            try data.write(to: url, options: options)
        } catch {
            throw error
        }
    }
}
