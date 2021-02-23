//
//  WallpaperManager.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/17.
//

import AppKit
import Combine

class WallpaperManager {
    static let shared = WallpaperManager()

    var autoChangeInterval: TimeInterval? {
        willSet {
            timerCancellable?.cancel()
            if let timeInterval = newValue {
                timerPublisher = Timer.publish(every: timeInterval, on: .main, in: .common)
                timerCancellable = timerPublisher.connect()
            }
        }
    }

    var timerPublisher: Timer.TimerPublisher

    var directory: URL {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "8TA5C5ASM9.me.jiaxin.SimpleDesktops")!.appendingPathComponent("Wallpapers")

        // Create the directory if it does not exist
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        return url
    }

    func setWallpaper(with url: URL) {
        // TODO: log
        NSScreen.screens.forEach { screen in
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }

        // Multi workspace
        if let observer = workspaceChangeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        workspaceChangeObserver = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { _ in
            // Set wallpaper when workspace changed
            NSScreen.screens.forEach { screen in
                try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
            }
        }
    }

    private var timerCancellable: Cancellable?

    private var workspaceChangeObserver: NSObjectProtocol?

    private init() {
        timerPublisher = Timer.publish(every: .infinity, on: .main, in: .common)
    }

    deinit {
        if let observer = workspaceChangeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }
}
