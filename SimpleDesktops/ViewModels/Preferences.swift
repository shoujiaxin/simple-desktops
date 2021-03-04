//
//  Preferences.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import Combine
import Foundation

class Preferences: ObservableObject {
    @Published private var options = Options()

    private var autosaveCancellable: AnyCancellable?

    init() {
        autosaveCancellable = $options.sink { options in
            options.save()
        }

        if options.autoChange {
            WallpaperManager.shared.autoChangeInterval = options.changeInterval.rawValue
        }
    }

    var autoChange: Bool {
        get {
            options.autoChange
        }
        set {
            options.autoChange = newValue
            WallpaperManager.shared.autoChangeInterval = newValue ? options.changeInterval.rawValue : nil
        }
    }

    var changeInterval: TimeInterval {
        get {
            options.changeInterval.rawValue
        }
        set {
            options.changeInterval = Options.ChangeInterval(rawValue: newValue)!
            WallpaperManager.shared.autoChangeInterval = options.autoChange ? options.changeInterval.rawValue : nil
        }
    }

    var allChangeIntervals: [Options.ChangeInterval] {
        Options.ChangeInterval.allCases
    }
}
