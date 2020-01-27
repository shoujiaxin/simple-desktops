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

    // Default options tuple
    static let defaultOptions = (
        simpleDesktopsMaxPage: 51, // Max page of Simple Desktops
        refreshInterval: 3600
    )

    struct OptionsInfo {
        static let simpleDesktopsMaxPage = "SimpleDesktopsMaxPage"
        static let refreshInterval = "RefreshInterval"
    }

    var simpleDesktopsMaxPage = Options.defaultOptions.simpleDesktopsMaxPage
    var refreshInterval = Options.defaultOptions.refreshInterval

    func loadOptions() {
        let preferences = UserDefaults.standard
        if preferences.integer(forKey: OptionsInfo.simpleDesktopsMaxPage) == 0 {
            simpleDesktopsMaxPage = Options.defaultOptions.simpleDesktopsMaxPage
            refreshInterval = Options.defaultOptions.refreshInterval
            saveOptions()
            return
        }

        simpleDesktopsMaxPage = preferences.integer(forKey: OptionsInfo.simpleDesktopsMaxPage)
        refreshInterval = preferences.integer(forKey: OptionsInfo.refreshInterval)
    }

    func saveOptions() {
        let preferences = UserDefaults.standard

        preferences.set(simpleDesktopsMaxPage, forKey: OptionsInfo.simpleDesktopsMaxPage)
        preferences.set(refreshInterval, forKey: OptionsInfo.refreshInterval)
    }
}
