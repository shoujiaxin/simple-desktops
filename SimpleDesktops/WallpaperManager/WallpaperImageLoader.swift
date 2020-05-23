//
//  WallpaperImageLoader.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/5/23.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

#if DEBUG
    import os.log
#endif

class WallpaperImageLoader {
    // Singleton pattern
    public static let shared = WallpaperImageLoader()

    #if DEBUG
        private let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "WallpaperImageLoader")
    #endif

    /// Download the image from link to path
    /// - Parameters:
    ///   - link: Source link of the image
    ///   - path: Path to save the image
    ///   - completionHandler: Callback of completion
    public func downloadImage(from link: String, to path: URL, completionHandler: @escaping (Error?) -> Void) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path.path) {
            DispatchQueue(label: "WallpaperImageSource.downloadImage").async {
                completionHandler(nil)
            }
            return
        }

        #if DEBUG
            os_log("Downloading image: %s", log: osLog, type: .debug, link)
        #endif

        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: URL(string: link)!) { url, _, error in
            if let error = error {
                completionHandler(error)
                return
            }

            do {
                try fileManager.moveItem(at: url!, to: path)
            } catch {
                completionHandler(error)
                return
            }

            completionHandler(nil)
        }

        task.resume()
    }

    /// Get the image from link
    /// - Parameters:
    ///   - link: Source link of the image
    ///   - completionHandler: Callback of completion
    public func fetchImage(from link: String, completionHandler: @escaping (NSImage?, Error?) -> Void) {
        #if DEBUG
            os_log("Fetching image: %s", log: osLog, type: .debug, link)
        #endif

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: URL(string: link)!) { data, _, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }

            completionHandler(NSImage(data: data!), nil)
        }

        task.resume()
    }
}
