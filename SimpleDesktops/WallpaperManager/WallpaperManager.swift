//
//  WallpaperManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/30.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import CoreData
import os.log

class WallpaperManager {
    public var dataSource = SimpleDesktopsSource()
    public var historyWallpapers: [ImageInfo] = []
    public var wallpaperDirectory = "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])/\((Bundle.main.infoDictionary!["CFBundleName"])!)/Wallpapers"

    private static var managedObjectContext: NSManagedObjectContext!
    private static var observer: NSObjectProtocol?
    private var timer: Timer?

    public enum WallpaperError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case fileNotExists
        case noImage
        case unknownImageFormat
    }

    init() {
        let appDelegate = NSApp.delegate as! AppDelegate
        WallpaperManager.managedObjectContext = appDelegate.persistentContainer.viewContext

        // Get history wallpapers from database
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: dataSource.entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: dataSource.entity.property.timeStamp, ascending: false)]
        if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
            if results.count > 0 {
                historyWallpapers.removeAll(keepingCapacity: true)
                for result in results {
                    historyWallpapers.append(dataSource.getImageInfo(from: result))
                }
            }
        }
    }

    /// Set wallpaper for all workspaces (desktops) on all screens
    /// - Parameter handler: Callback of completion
    public func changeWallpaper(completionHandler handler: @escaping (Error?) -> Void) {
        // Save the image to ~/Library/Containers/me.jiaxin.SimpleDesktops/Data/Library/Application Support/SimpleDesktops/Wallpapers/
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: wallpaperDirectory) {
            // Create the folder if it not exists
            do {
                try fileManager.createDirectory(atPath: wallpaperDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                let queue = DispatchQueue(label: "WallpaperManager.changeWallpaper")
                queue.async {
                    handler(error)
                }
                return
            }
        }

        let directory = URL(fileURLWithPath: wallpaperDirectory)
        downloadWallpaper(to: directory) { error in
            if let error = error {
                handler(error)
                return
            }

            // Change wallpaper for current workspaces
            let url = URL(fileURLWithPath: self.dataSource.imageInfo.name!, relativeTo: directory)
            do {
                try self.setWallpaper(with: url)
            } catch {
                handler(error)
                return
            }

            // Change wallpaper for other workspaces when changed to
            if let observer = WallpaperManager.observer {
                NSWorkspace.shared.notificationCenter.removeObserver(observer, name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
            }
            WallpaperManager.observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { _ in
                // Assume the image will NOT be removed manually
                try? self.setWallpaper(with: url)
            }
            handler(nil)
        }
    }

    /// Set wallpaper for all workspaces (desktops) on all screens automatically
    /// - Parameter timeInterval: Time interval to change wallpapers
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
    public func downloadWallpaper(to directory: URL, completionHandler handler: @escaping (Error?) -> Void) {
        guard let wallpaperName = dataSource.imageInfo.name else {
            let queue = DispatchQueue(label: "WallpaperManager.downloadWallpaper")
            queue.async {
                handler(WallpaperError.noImage)
            }
            return
        }

        if !directory.hasDirectoryPath {
            let queue = DispatchQueue(label: "WallpaperManager.downloadWallpaper")
            queue.async {
                handler(WallpaperError.failedToSaveImage)
            }
            return
        }

        let url = URL(fileURLWithPath: wallpaperName, relativeTo: directory)

        // Already downloaded
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            let queue = DispatchQueue(label: "WallpaperManager.downloadWallpaper")
            queue.async {
                handler(nil)
            }
            return
        }

        dataSource.getFullImage { image, error in
            if let error = error {
                handler(error)
                return
            }

            guard let imageFormat = self.dataSource.imageInfo.format else {
                handler(WallpaperError.unknownImageFormat)
                return
            }

            do {
                try image?.write(to: url, using: imageFormat)
                handler(nil)
            } catch {
                handler(error)
                return
            }
        }
    }

    public func getHistoryPreview(at index: Int, completionHandler handler: @escaping (NSImage?, Error?) -> Void) {
        if let previewImageLink = historyWallpapers[index].previewLink {
            dataSource.getImage(form: previewImageLink, completionHandler: handler)
        }
    }

    public func getLatestPreview(completionHandler handler: @escaping (NSImage?, Error?) -> Void) {
        guard dataSource.imageInfo.name == nil else {
            // The app is already running, get the latest image from memory
            dataSource.getPreviewImage(completionHandler: handler)
            return
        }

        // Just start the app, get the latest image from database
        if historyWallpapers.isEmpty {
            // Run the app for the first time, get a new image
            updatePreview(completionHandler: handler)
        } else {
            // Found history from database
            dataSource.imageInfo = historyWallpapers.first!
            dataSource.getPreviewImage(completionHandler: handler)
        }
    }

    public func removeFromHistory(at index: Int) {
        // Remove the record from database
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: dataSource.entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(dataSource.entity.property.name) = %@", historyWallpapers[index].name!)
        fetchRequest.fetchLimit = 1
        if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
            if results.count > 0 {
                WallpaperManager.managedObjectContext.delete(results[0])
                try? WallpaperManager.managedObjectContext.save()
            }
        }

        // Move the file to trash
        let imagePath = "\(wallpaperDirectory)/\(historyWallpapers[index].name!)"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imagePath) {
            try? fileManager.trashItem(at: URL(fileURLWithPath: imagePath), resultingItemURL: nil)
        }

        historyWallpapers.remove(at: index)
    }

    public func selectFromHistory(at index: Int) {
        dataSource.imageInfo = historyWallpapers[index]

        // Move the wallpaper to the first
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: dataSource.entity.name)
        fetchRequest.predicate = NSPredicate(format: "\(dataSource.entity.property.name) = %@", historyWallpapers[index].name!)
        fetchRequest.fetchLimit = 1
        if let results = try? (WallpaperManager.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]) {
            if results.count > 0 {
                results[0].setValue(Date(), forKey: dataSource.entity.property.timeStamp)
                try? WallpaperManager.managedObjectContext.save()
            }
        }

        if index != 0 {
            let item = historyWallpapers.remove(at: index)
            historyWallpapers.insert(item, at: 0)
        }
    }

    /// Update preview image randomly
    /// - Parameter handler: Callback of completion
    public func updatePreview(completionHandler handler: @escaping (NSImage?, Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.updatePreview")
        queue.async {
            do {
                try self.updateImageFromSource()
            } catch {
                handler(nil, error)
                return
            }

            self.dataSource.getPreviewImage(completionHandler: handler)
        }
    }

    // MARK: Private Methods

    @objc private func changeWallpaperBackground(sender _: Timer) {
        if !Options.shared.changePicture {
            timer?.invalidate() // Stop the timer
            return
        }

        let queue = DispatchQueue(label: "WallpaperManager.changeWallpaperBackground")
        queue.async {
            try? self.updateImageFromSource()

            self.changeWallpaper { error in
                if let error = error {
                    let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "changeWallpaper")
                    os_log("Failed to change wallpaper: %{public}@", log: osLog, type: .error, error.localizedDescription)
                }
            }

            // Pre-cache preview image
            self.dataSource.getPreviewImage { _, error in
                if let error = error {
                    let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "getPreviewImage")
                    os_log("Failed to get preview image: %{public}@", log: osLog, type: .error, error.localizedDescription)
                }
            }
        }
    }

    private func setWallpaper(with url: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else {
            throw WallpaperError.fileNotExists
        }

        let screens = NSScreen.screens
        do {
            for screen in screens {
                try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
            }
        } catch {
            let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "setWallpaper")
            os_log("Failed to set wallpaper: %{public}@", log: osLog, type: .error, error.localizedDescription)
            throw error
        }
    }

    private func updateImageFromSource() throws {
        guard dataSource.randomImage() else {
            let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "updateImageFromSource")
            os_log("Failed to update image from source", log: osLog, type: .error)
            throw WallpaperError.failedToLoadImage
        }

        historyWallpapers.insert(dataSource.imageInfo, at: 0)

        // Add to database
        let obj = NSEntityDescription.insertNewObject(forEntityName: dataSource.entity.name, into: WallpaperManager.managedObjectContext)
        obj.setValue(dataSource.imageInfo.fullLink, forKey: dataSource.entity.property.fullLink)
        obj.setValue(dataSource.imageInfo.name, forKey: dataSource.entity.property.name)
        obj.setValue(dataSource.imageInfo.previewLink, forKey: dataSource.entity.property.previewLink)
        obj.setValue(Date(), forKey: dataSource.entity.property.timeStamp)
        do {
            try WallpaperManager.managedObjectContext.save()
        } catch {
            throw error
        }
    }
}

private extension NSImage {
    func write(to url: URL, using format: NSBitmapImageRep.FileType, options: Data.WritingOptions = .atomic) throws {
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
