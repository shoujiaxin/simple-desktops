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
    var historyWallpapers: [SimpleDesktopsSource.ImageInfo] = []

    private var source = SimpleDesktopsSource()
    private var timer: Timer?
    private static var observer: NSObjectProtocol?
    private static var managedObjectContext: NSManagedObjectContext!

    enum WallpaperError: Error {
        case noImage
        case fileNotExists
        case unknownImageFormat
    }

    init() {
        let appDelegate = NSApp.delegate as! AppDelegate
        WallpaperManager.managedObjectContext = appDelegate.persistentContainer.viewContext
    }

    /// Set wallpaper for all workspaces (desktops) on all screens
    /// - Parameter handler: Callback of completion
    public func changeWallpaper(completionHandler handler: @escaping (_ error: Error?) -> Void) {
        // Save the image to ~/Library/Containers/me.jiaxin.SimpleDesktops/Data/Library/Application Support/SimpleDesktops/Wallpaper/
        let wallpaperDirectory = "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])/\((Bundle.main.infoDictionary!["CFBundleName"])!)/Wallpapers/"

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: wallpaperDirectory) {
            // Create the folder if it not exists
            do {
                try fileManager.createDirectory(atPath: wallpaperDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                handler(error)
                return
            }
        }
//        else {
//            // Clear old wallpapers
//            if let files = try? fileManager.contentsOfDirectory(atPath: wallpaperDirectory) {
//                for file in files {
//                    do {
//                        try fileManager.trashItem(at: URL(fileURLWithPath: wallpaperDirectory + "/\(file)"), resultingItemURL: nil)
//                    } catch {
//                        handler(error)
//                        return
//                    }
//                }
//            }
//        }

        let directory = URL(fileURLWithPath: wallpaperDirectory)
        downloadWallpaper(to: directory) { error in
            if let error = error {
                handler(error)
                return
            }

            // Change wallpaper for current workspaces
            let url = URL(fileURLWithPath: self.source.imageInfo.name!, relativeTo: directory)
            self.setWallpaper(with: url)

            // Change wallpaper for other workspaces when changed to
            if let observer = WallpaperManager.observer {
                NSWorkspace.shared.notificationCenter.removeObserver(observer, name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
            }
            WallpaperManager.observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { _ in
                self.setWallpaper(with: url)
            }
            handler(nil)
        }
    }

    public func changeWallpaper(every timeInterval: TimeInterval) {
        if let timer = timer {
            timer.invalidate()
        }

        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(changeWallpaperBackground(sender:)), userInfo: nil, repeats: true)
    }

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

            guard let imageFormat = self.source.imageInfo.format else {
                handler(WallpaperError.unknownImageFormat)
                return
            }

            switch self.source.imageInfo.format {
            case .png, .jpeg, .gif:
                do {
                    try image?.write(using: imageFormat, to: url)
                    handler(nil)
                } catch {
                    handler(error)
                    return
                }
            default:
                handler(WallpaperError.unknownImageFormat)
                return
            }
        }
    }

    public func getHistoryPreview(at index: Int, completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        if let previewLink = historyWallpapers[index].previewLink {
            source.getImage(form: previewLink, completionHandler: handler)
        }
    }

    public func getHistoryWallpapers() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SDImage")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]

        if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
            if results.count > 0 {
                historyWallpapers.removeAll()
                for result in results {
                    historyWallpapers.append(SimpleDesktopsSource.ImageInfo(withPreviewLink: result.value(forKey: "previewLink") as! String))
                }
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

    public func removeFromHistory(at index: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SDImage")
        fetchRequest.predicate = NSPredicate(format: "name = %@", historyWallpapers[index].name!)
        fetchRequest.fetchLimit = 1

        if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
            if results.count > 0 {
                WallpaperManager.managedObjectContext.delete(results[0])
                try? WallpaperManager.managedObjectContext.save()
            }
        }

        historyWallpapers.remove(at: index)
    }

    public func selectFromHistory(at index: Int) {
        source.imageInfo = historyWallpapers[index]

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SDImage")
        fetchRequest.predicate = NSPredicate(format: "name = %@", historyWallpapers[index].name!)
        fetchRequest.fetchLimit = 1

        if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
            if results.count > 0 {
                results[0].setValue(Date(), forKey: "timeStamp")
                try? WallpaperManager.managedObjectContext.save()
            }
        }
    }

    /// Update preview image randomly
    /// - Parameter handler: Callback of completion
    public func updatePreview(completionHandler handler: @escaping (_ image: NSImage?, _ error: Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.updatePreview")
        queue.async {
            do {
                try self.updateImageFromSource()
            } catch {
                handler(nil, error)
                return
            }

            self.source.getPreviewImage(completionHandler: handler)
        }
    }

    @objc private func changeWallpaperBackground(sender _: Timer) {
        if !Options.shared.changePicture {
            timer?.invalidate() // Stop the timer
            return
        }

        let queue = DispatchQueue(label: "WallpaperManager.changeWallpaperBackground")
        queue.async {
            try? self.updateImageFromSource()

            let semaphore = DispatchSemaphore(value: 0)
            self.changeWallpaper { _ in
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .distantFuture)
        }
    }

    private func setWallpaper(with url: URL) {
        let screens = NSScreen.screens
        for screen in screens {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }
    }

    private func updateImageFromSource() throws {
        source.randomImage()

        // Add to database
        let obj = NSEntityDescription.insertNewObject(forEntityName: "SDImage", into: WallpaperManager.managedObjectContext)
        obj.setValue(source.imageInfo.name, forKey: "name")
        obj.setValue(source.imageInfo.previewLink, forKey: "previewLink")
        obj.setValue(Date(), forKey: "timeStamp")

        do {
            try WallpaperManager.managedObjectContext.save()
        } catch {
            throw error
        }
    }
}

private extension NSImage {
    func write(using format: NSBitmapImageRep.FileType, to url: URL, options: Data.WritingOptions = .atomic) throws {
        guard let tiffRepresentation = tiffRepresentation,
            let bitmapImageRep = NSBitmapImageRep(data: tiffRepresentation),
            let data = bitmapImageRep.representation(using: format, properties: [:]) else {
            return
        }

        do {
            try data.write(to: url, options: options)
        } catch {
            throw error
        }
    }
}
