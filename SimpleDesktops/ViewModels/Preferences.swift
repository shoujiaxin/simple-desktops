//
//  Preferences.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import Combine

class Preferences: ObservableObject {
    @Published private var options = Options()

    private var autosaveCancellable: AnyCancellable?

    init() {
        autosaveCancellable = $options.sink { options in
            options.save()
        }

        if options.autoChange {
            WallpaperManager.shared.autoChangeInterval = options.changeInterval.seconds
        }
    }

    var autoChange: Bool {
        options.autoChange
    }

    var changeInterval: Int {
        options.changeInterval.rawValue
    }

    var allChangeIntervals: [Options.ChangeInterval] {
        Options.ChangeInterval.allCases
    }

    func setAutoChange(_ enable: Bool) {
        options.autoChange = enable
        WallpaperManager.shared.autoChangeInterval = enable ? options.changeInterval.seconds : nil
    }

    func selectChangeInterval(at tag: Int) {
        options.changeInterval = Options.ChangeInterval(rawValue: tag) ?? .everyHour
        WallpaperManager.shared.autoChangeInterval = options.changeInterval.seconds
    }
}
