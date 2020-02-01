//
//  Options.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/27.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Foundation

class Options {
    static let shared = Options()

    enum ChangeInterval: UInt8 {
        case everyMinute
        case everyFiveMinutes
        case everyFifteenMinutes
        case everyHour
        case everyDay

        static func from(rawValue: Int) -> ChangeInterval {
            switch rawValue {
            case 0: return everyMinute
            case 1: return everyFiveMinutes
            case 2: return everyFifteenMinutes
            case 3: return everyHour
            case 4: return everyDay
            default: return everyHour
            }
        }
    }

    // Default options tuple
    static let defaultOptions = (
        simpleDesktopsMaxPage: 51, // Max page of Simple Desktops
        changePicture: false,
        changeInterval: ChangeInterval.everyHour
    )

    struct OptionsInfo {
        static let simpleDesktopsMaxPage = "SimpleDesktopsMaxPage"
        static let changePicture = "AutoPictureChange"
        static let changeInterval = "PictureChangeInterval"
    }

    var simpleDesktopsMaxPage = Options.defaultOptions.simpleDesktopsMaxPage
    var changePicture = Options.defaultOptions.changePicture
    var changeInterval = Options.defaultOptions.changeInterval

    func loadOptions() {
        let preferences = UserDefaults.standard
        if preferences.integer(forKey: OptionsInfo.simpleDesktopsMaxPage) == 0 {
            simpleDesktopsMaxPage = Options.defaultOptions.simpleDesktopsMaxPage
            changePicture = Options.defaultOptions.changePicture
            changeInterval = Options.defaultOptions.changeInterval
            saveOptions()
            return
        }

        simpleDesktopsMaxPage = preferences.integer(forKey: OptionsInfo.simpleDesktopsMaxPage)
        changePicture = preferences.bool(forKey: OptionsInfo.changePicture)
        changeInterval = ChangeInterval.from(rawValue: preferences.integer(forKey: OptionsInfo.changeInterval))
    }

    func saveOptions() {
        let preferences = UserDefaults.standard

        preferences.set(simpleDesktopsMaxPage, forKey: OptionsInfo.simpleDesktopsMaxPage)
        preferences.set(changePicture, forKey: OptionsInfo.changePicture)
        preferences.set(changeInterval.rawValue, forKey: OptionsInfo.changeInterval)
    }
}
