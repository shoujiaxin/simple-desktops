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
            WallpaperManager.shared.autoChangeInterval = options.changeInterval
        }
    }

    var autoChange: Bool {
        get {
            options.autoChange
        }
        set {
            options.autoChange = newValue
            WallpaperManager.shared.autoChangeInterval = newValue ? options.changeInterval : nil
        }
    }

    var changeInterval: ChangeInterval {
        get {
            options.changeInterval
        }
        set {
            options.changeInterval = newValue
            WallpaperManager.shared.autoChangeInterval = options.autoChange ? newValue : nil
        }
    }

    var timeChangeIntervals: [ChangeInterval] {
        ChangeInterval.allCases.filter { $0.rawValue >= 0 }
    }

    var eventChangeIntervals: [ChangeInterval] {
        ChangeInterval.allCases.filter { $0.rawValue < 0 }
    }
}
