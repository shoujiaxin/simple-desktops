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
    }

    func selectChangeInterval(at tag: Int) {
        options.changeInterval = Options.ChangeInterval(rawValue: tag) ?? .everyHour
    }
}
