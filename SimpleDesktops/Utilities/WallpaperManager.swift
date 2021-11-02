//
//  WallpaperManager.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/17.
//

import AppKit
import Combine

class WallpaperManager {
    static let shared = WallpaperManager()

    /// The directory where wallpaper images are stored.
    static let directory: URL = {
        let url = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: "8TA5C5ASM9.me.jiaxin.SimpleDesktops"
            )!
            .appendingPathComponent("Wallpapers")

        // Create the directory if it does not exist
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        return url
    }()

    var autoChangePublisher: AnyPublisher<Date, Never>

    /// Time interval for automatic wallpaper change. Set to `nil` to stop.
    var autoChangeInterval: ChangeInterval? {
        willSet {
            timerCancellable?.cancel()
            wakeFromSleepObserver.map {
                NSWorkspace.shared.notificationCenter.removeObserver($0)
            }
            guard let interval = newValue else {
                return
            }

            switch interval {
            case .whenWakingFromSleep:
                let subject = PassthroughSubject<Date, Never>()
                wakeFromSleepObserver = NSWorkspace.shared.notificationCenter.addObserver(
                    forName: NSWorkspace.didWakeNotification,
                    object: nil,
                    queue: nil
                ) { _ in
                    subject.send(Date())
                }
                autoChangePublisher = subject.eraseToAnyPublisher()
            case .everyMinute,
                 .everyFiveMinutes,
                 .everyFifteenMinutes,
                 .everyThirtyMinutes,
                 .everyHour,
                 .everyDay:
                let publihser = Timer.publish(every: interval.seconds!, on: .main, in: .common)
                autoChangePublisher = publihser.eraseToAnyPublisher()
                timerCancellable = publihser.connect()
            }
        }
    }

    /// Set wallpaper for all Spaces.
    /// - Parameter url: A file URL to the image.
    func setWallpaper(with url: URL) {
        // TODO: Log
        NSScreen.screens.forEach { screen in
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }

        // Multi workspace
        workspaceChangeObserver.map {
            NSWorkspace.shared.notificationCenter.removeObserver($0)
        }
        workspaceChangeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: nil
        ) { _ in
            // Set wallpaper when Spaces changed
            NSScreen.screens.forEach { screen in
                try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
            }
        }
    }

    private var timerCancellable: Cancellable?

    private var wakeFromSleepObserver: NSObjectProtocol?

    private var workspaceChangeObserver: NSObjectProtocol?

    private init() {
        autoChangePublisher = Timer.publish(every: .infinity, on: .main, in: .common)
            .eraseToAnyPublisher()
    }

    deinit {
        wakeFromSleepObserver.map {
            NSWorkspace.shared.notificationCenter.removeObserver($0)
        }

        workspaceChangeObserver.map {
            NSWorkspace.shared.notificationCenter.removeObserver($0)
        }
    }
}
