//
//  Options.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import SwiftUI

struct Options: Codable {
    enum ChangeInterval: Int, CaseIterable, Identifiable, Codable {
        case everyMinute
        case everyFiveMinutes
        case everyFifteenMinutes
        case everyThirtyMinutes
        case everyHour
        case everyDay

        var id: Int {
            rawValue
        }

        var description: LocalizedStringKey {
            switch self {
            case .everyMinute: return "Every minute"
            case .everyFiveMinutes: return "Every 5 minutes"
            case .everyFifteenMinutes: return "Every 15 minutes"
            case .everyThirtyMinutes: return "Every 30 minutes"
            case .everyHour: return "Every hour"
            case .everyDay: return "Every day"
            }
        }

        var seconds: TimeInterval {
            switch self {
            case .everyMinute: return 60
            case .everyFiveMinutes: return 60 * 5
            case .everyFifteenMinutes: return 60 * 15
            case .everyThirtyMinutes: return 60 * 30
            case .everyHour: return 60 * 60
            case .everyDay: return 60 * 60 * 24
            }
        }
    }

    var autoChange: Bool = true
    var changeInterval: ChangeInterval = .everyHour

    init() {
        if let data = try? JSONEncoder().encode(self),
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
           let savedData = try? JSONSerialization.data(withJSONObject: UserDefaults.standard.dictionaryWithValues(forKeys: Array(dictionary.keys)), options: .fragmentsAllowed),
           let options = try? JSONDecoder().decode(Options.self, from: savedData)
        {
            self = options
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(self),
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        {
            UserDefaults.standard.setValuesForKeys(dictionary)
        }
    }
}
