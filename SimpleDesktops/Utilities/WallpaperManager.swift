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

    var imageURL: URL? {
        willSet {
            if let url = newValue {
                for screen in NSScreen.screens {
                    try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
            }
        }
    }

    var autoChangeInterval: TimeInterval? {
        willSet {
            timerCancellable?.cancel()
            if let timeInterval = newValue {
                timerCancellable = Timer.publish(every: timeInterval, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        self.receiveHandler()
                    }
            }
        }
    }

    var receiveHandler: () -> Void = {}

    private var timerCancellable: AnyCancellable?

    private init() {}
}
