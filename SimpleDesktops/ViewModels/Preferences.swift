//
//  Preferences.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import Foundation

class Preferences: ObservableObject {
    @Published var autoChange: Bool {
        willSet {
            options.autoChange = newValue
            options.save()
            WallpaperManager.shared.autoChangeInterval = newValue ? options.changeInterval : nil
        }
    }

    @Published var changeInterval: ChangeInterval {
        willSet {
            options.changeInterval = newValue
            options.save()
            WallpaperManager.shared.autoChangeInterval = options.autoChange ? newValue : nil
        }
    }

    private var options = Options()

    init() {
        autoChange = options.autoChange
        changeInterval = options.changeInterval

        if options.autoChange {
            WallpaperManager.shared.autoChangeInterval = options.changeInterval
        }
    }
}
