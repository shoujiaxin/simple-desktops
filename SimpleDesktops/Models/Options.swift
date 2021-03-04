//
//  Options.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import SwiftUI

struct Options: Codable {
    enum ChangeInterval: TimeInterval, CaseIterable, Codable {
        case everyMinute = 60
        case everyFiveMinutes = 300
        case everyFifteenMinutes = 900
        case everyThirtyMinutes = 1800
        case everyHour = 3600
        case everyDay = 86400

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
    }

    var autoChange: Bool = true
    var changeInterval: ChangeInterval = .everyHour

    init() {
        let keys = Mirror(reflecting: self).children.compactMap { $0.label }
        if let data = try? JSONSerialization.data(withJSONObject: UserDefaults.standard.dictionaryWithValues(forKeys: keys), options: .fragmentsAllowed),
           let options = try? JSONDecoder().decode(Options.self, from: data)
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
