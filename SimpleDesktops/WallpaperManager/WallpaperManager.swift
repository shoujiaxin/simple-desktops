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

    enum WallpaperError: Error {
        case noImage
        case fileNotExists
    }

    init() {
        let appDelegate = NSApp.delegate as! AppDelegate
        WallpaperManager.managedObjectContext = appDelegate.persistentContainer.viewContext
    }

    /// Set wallpaper for all workspaces (desktops) on all screens
    /// - Parameter handler: Callback of completion
    public func changeWallpaper(completionHandler handler: @escaping (_ error: Error?) -> Void) {
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

        let directory = URL(fileURLWithPath: wallpaperDirectory)
        downloadWallpaper(to: directory) { error in
            if let error = error {
                handler(error)
                return
            }

            let url = URL(fileURLWithPath: self.source.imageInfo.name!, relativeTo: directory)
            self.setWallpaper(with: url)
            NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { _ in
                self.setWallpaper(with: url)
            }
            handler(nil)
        }
    }

    public func changeWallpaper(every _: TimeInterval, completionHandler _: @escaping (_ error: Error?) -> Void) {}

    /// Download image to hard disk
    /// - Parameters:
    ///   - url: URL of the directory to store the image
    ///   - handler: Callback of completion
    public func downloadWallpaper(to directory: URL, completionHandler handler: @escaping (_ error: Error?) -> Void) {
        guard let wallpaperName = source.imageInfo.name else {
            handler(WallpaperError.noImage)
            return
        }

        if !directory.hasDirectoryPath {
            handler(WallpaperError.fileNotExists)
            return
        }

        let url = URL(fileURLWithPath: wallpaperName, relativeTo: directory)

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

    public func getLatestPreview(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        guard source.imageInfo.previewLink == nil else {
            // The app is already running, get the latest image from memory
            source.getPreviewImage(completionHandler: handler)
            return
        }

        let queue = DispatchQueue(label: "WallpaperManager.getLastestPreview")
        queue.async {
            // Just start the app, get the latest image from database
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

    /// Update preview image randomly
    /// - Parameter handler: Callback of completion
    public func updatePreview(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.updatePreview")
        queue.async {
            self.updateImageFromSource()

            do {
                try WallpaperManager.managedObjectContext.save()
            } catch {
                handler(nil, error)
                return
            }

            self.source.getPreviewImage(completionHandler: handler)
        }
    }

    private func setWallpaper(with url: URL) {
        let screens = NSScreen.screens
        for screen in screens {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }
    }

    private func updateImageFromSource() {
        source.randomImage()

        // Add to database
        let obj = NSEntityDescription.insertNewObject(forEntityName: "SDImage", into: WallpaperManager.managedObjectContext)
        obj.setValue(source.imageInfo.name, forKey: "name")
        obj.setValue(source.imageInfo.previewLink, forKey: "previewLink")
        obj.setValue(Date(), forKey: "timeStamp")
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
