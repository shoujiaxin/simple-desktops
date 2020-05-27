//
//  WallpaperManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/30.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import os.log
import SDWebImage

class WallpaperManager {
    public enum WallpaperError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case fileNotExists
        case noImage
        case unknownImageFormat
    }

    public var image: WallpaperImage?
    public let source: WallpaperImageSource!
    public let wallpaperDirectory = URL(fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])/\((Bundle.main.infoDictionary!["CFBundleName"])!)/Wallpapers", isDirectory: true)

    private static var observer: NSObjectProtocol?
    private var timer: Timer?
    private let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "WallpaperManager")

    init() {
        source = SimpleDesktopsSource()

        if source.images.isEmpty {
            // Launch for the first time
            update { image, _ in
                self.image = image
            }
        } else {
            image = source.images.first
        }
    }

    // MARK: Public Methods

    public func change(completionHandler: @escaping (Error?) -> Void) {
        guard let imageName = image?.name else {
            completionHandler(WallpaperError.noImage)
            return
        }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: wallpaperDirectory.path) {
            // Create the folder if it not exists
            do {
                try fileManager.createDirectory(at: wallpaperDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completionHandler(error)
                return
            }
        }

        SDWebImageDownloader.shared.downloadImage(with: image?.fullUrl, options: .highPriority, progress: nil) { _, data, error, finished in
            if let error = error {
                completionHandler(error)
                return
            }

            if finished {
                let url = self.wallpaperDirectory.appendingPathComponent(imageName)

                // Save & change wallpaper
                do {
                    try data?.write(to: url)
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
    }

    public func change(every timeInterval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(changeBackground(sender:)), userInfo: nil, repeats: true)
    }

    public func update(completionHandler: @escaping (WallpaperImage?, Error?) -> Void) {
        let queue = DispatchQueue(label: "WallpaperManager.update")
        queue.async {
            var retryCnt = 5
            while !self.source.updateImage(), retryCnt > 0 {
                retryCnt -= 1
            }

            DispatchQueue.main.sync {
                if retryCnt > 0 {
                    completionHandler(self.source.images.first, nil)
                } else {
                    completionHandler(nil, WallpaperError.failedToLoadImage)
                }
            }
        }
    }

    // MARK: Private Methods

    @objc private func changeBackground(sender _: Timer) {
        if !Options.shared.changePicture {
            timer?.invalidate() // Stop the timer
            return
        }

        update { image, _ in
            self.image = image
            self.change { error in
                if let error = error {
                    os_log("Failed to change wallpaper: %{public}@", log: self.osLog, type: .error, error.localizedDescription)
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

            os_log("Wallpaper is changed to: %s", log: osLog, type: .info, url.path)
        } catch {
            os_log("Failed to set wallpaper: %{public}@", log: osLog, type: .error, error.localizedDescription)

            throw error
        }
    }
}
