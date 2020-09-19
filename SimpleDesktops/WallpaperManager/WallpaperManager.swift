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
    public static let shared = WallpaperManager()
    public static let wallpaperDirectory = URL(fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])/\((Bundle.main.infoDictionary!["CFBundleName"])!)/Wallpapers", isDirectory: true)

    public enum WallpaperError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case fileNotExists
        case noImage
        case unknownImageFormat
    }

    public var image: WallpaperImage? {
        willSet {
            if let newImage = newValue {
                DispatchQueue.main.async {
                    self.delegate?.updatePreview(with: newImage)
                }
            }
        }
    }

    public var images: [WallpaperImage] {
        return source.images
    }

    public weak var delegate: WallpaperManagerDelegate?

    public var timer: Timer?

    private let source: WallpaperImageSource = SimpleDesktopsSource()

    private let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "WallpaperManager")

    init() {
        image = source.images.first

        // Change wallpaper for other workspaces when changed to
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { _ in
            // Assume the image will NOT be removed manually
            try? self.setWallpaper()
        }

        // Update wallpaper when wake from sleep
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { _ in
            guard let nextChangeDate = Options.shared.nextChangeDate else {
                return
            }

            let currentDate = Date()
            if currentDate > nextChangeDate {
                self.changeBackground(sender: nil)

                self.resetTimer(with: Options.shared.changeInterval.seconds)
            }
        }
    }

    // MARK: Public Methods

    /// Set the wallpaper
    /// - Parameter completionHandler: Callback of completion
    public func change(completionHandler: @escaping (Error?) -> Void) {
        guard let imageName = image?.name else {
            completionHandler(WallpaperError.noImage)
            return
        }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: WallpaperManager.wallpaperDirectory.path) {
            // Create the folder if it not exists
            do {
                try fileManager.createDirectory(at: WallpaperManager.wallpaperDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completionHandler(error)
                return
            }
        }

        delegate?.startLoading(self)
        SDWebImageDownloader.shared.downloadImage(with: image?.fullUrl, options: .highPriority, progress: { receivedSize, expectedSize, _ in
            self.delegate?.loadingProgress(at: Double(receivedSize) / Double(expectedSize))
        }) { image, data, error, finished in
            self.delegate?.stopLoading(self)

            if let error = error {
                completionHandler(error)
                os_log("Failed to download image: %{public}@", log: self.osLog, type: .error, error.localizedDescription)
                return
            }

            if finished {
                let url = WallpaperManager.wallpaperDirectory.appendingPathComponent(imageName)

                // Save & change wallpaper
                do {
                    try data?.write(to: url)
                    try self.setWallpaper()

                    Utils.showNotification(withTitle: NSLocalizedString("Set Wallpaper Successfully", comment: ""), information: imageName, contentImage: image)
                    os_log("Wallpaper is changed to: %{public}@", log: self.osLog, type: .info, url.path)
                } catch {
                    completionHandler(error)

                    Utils.showNotification(withTitle: NSLocalizedString("Failed to Set Wallpaper", comment: ""), information: nil, contentImage: NSImage(named: NSImage.cautionName))
                    os_log("Failed to set wallpaper: %{public}@", log: self.osLog, type: .error, error.localizedDescription)
                    return
                }

                completionHandler(nil)
            }
        }
    }

    /// Delete history wallpaper by its name
    /// - Parameter name: Name of the wallpaper to be deleted
    public func delete(byName name: String) {
        HistoryImageManager.shared.delete(byName: name, fromEntity: source.entity)
    }

    public func resetTimer(with timeInterval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(changeBackground(sender:)), userInfo: nil, repeats: true)
    }

    /// Select the wallpaper from history
    /// - Parameter index: Index of the image selected
    public func selectImage(at index: Int) {
        image = images[index]
    }

    /// Fetch a new wallpaper image and add to history database
    /// - Parameter completionHandler: Callback of completion
    public func update(completionHandler: @escaping (Error?) -> Void) {
        delegate?.startLoading(self)
        let queue = DispatchQueue(label: "WallpaperManager.update")
        queue.async {
            var retryCnt = 5
            while retryCnt > 0 {
                if let image = self.source.updateImage() {
                    self.image = image
                    DispatchQueue.main.async {
                        self.delegate?.stopLoading(self)
                        completionHandler(nil)
                    }
                    return
                }
                retryCnt -= 1
            }

            DispatchQueue.main.async {
                self.delegate?.stopLoading(self)
                completionHandler(WallpaperError.failedToLoadImage)
            }
        }
    }

    // MARK: Private Methods

    @objc private func changeBackground(sender _: Any?) {
        if Options.shared.changeInterval == .everyDay, let nextChangeDate = Options.shared.nextChangeDate {
            let currentDate = Date()
            if currentDate < nextChangeDate {
                return
            }
        }

        update { error in
            if let error = error {
                os_log("Failed to update wallpaper: %{public}@", log: self.osLog, type: .error, error.localizedDescription)
            }

            self.change { error in
                if let error = error {
                    os_log("Failed to change wallpaper: %{public}@", log: self.osLog, type: .error, error.localizedDescription)
                }
            }
        }

        Options.shared.nextChangeDate = Options.shared.nextChangeDate?.addingTimeInterval(Options.shared.changeInterval.seconds)
    }

    private func setWallpaper() throws {
        guard let imageName = image?.name else {
            return
        }

        let url = WallpaperManager.wallpaperDirectory.appendingPathComponent(imageName)
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
            throw error
        }
    }
}
