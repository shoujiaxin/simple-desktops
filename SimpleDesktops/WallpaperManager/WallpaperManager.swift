//
//  WallpaperManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/30.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import os.log

class WallpaperManager {
    public enum WallpaperError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case fileNotExists
        case noImage
        case unknownImageFormat
    }

    public var directory: URL
    public var image: WallpaperImage?
    public let source: WallpaperImageSource?

    private static var observer: NSObjectProtocol?
    private var timer: Timer?

    init() {
        directory = URL(fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])/\((Bundle.main.infoDictionary!["CFBundleName"])!)/Wallpapers", isDirectory: true)

        source = SimpleDesktopsSource()

        if source!.images.isEmpty {
            // Launch for the first time
            let queue = DispatchQueue(label: "WallpaperManager.init")
            queue.async {
                while !(self.source!.updateImage()) {
                    // Empty
                }
                self.image = self.source!.images.first
            }
        } else {
            image = source!.images.first
        }
    }

    // MARK: Public Methods

    public func change(completionHandler: @escaping (Error?) -> Void) {
        guard let imageName = image?.name else {
            return
        }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            // Create the folder if it not exists
            do {
                try fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                DispatchQueue(label: "WallpaperManager.change").async {
                    completionHandler(error)
                }
                return
            }
        }

        let url = URL(fileURLWithPath: imageName, relativeTo: directory)
        image?.download(to: url) { error in
            if let error = error {
                completionHandler(error)
                return
            }

            // Change wallpaper for current workspaces
            do {
                try self.setWallpaper(with: url)
            } catch {
                completionHandler(error)
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

            completionHandler(nil)
        }
    }

    public func change(every timeInterval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(changeBackground(sender:)), userInfo: nil, repeats: true)
    }

    public func update(completionHandler: @escaping (NSImage?, Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.update")
        queue.async {
            while !(self.source!.updateImage()) {
                // Empty
            }
            self.image = self.source?.images.first

            self.image?.previewImage(completionHandler: completionHandler)
        }
    }

    // MARK: Private Methods

    @objc private func changeBackground(sender _: Timer) {
        if !Options.shared.changePicture {
            timer?.invalidate() // Stop the timer
            return
        }

        let queue = DispatchQueue(label: "WallpaperManager.changeBackground")
        queue.async {
            while !(self.source!.updateImage()) {
                // Empty
            }
            self.image = self.source?.images.first

            self.change { error in
                if let error = error {
                    let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "changeBackground")
                    os_log("Failed to change wallpaper: %{public}@", log: osLog, type: .error, error.localizedDescription)
                }
            }

            // Pre-cache preview image
            self.image?.previewImage(completionHandler: { _, error in
                if let error = error {
                    let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "changeBackground")
                    os_log("Failed to get preview image: %{public}@", log: osLog, type: .error, error.localizedDescription)
                }
            })
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
}
