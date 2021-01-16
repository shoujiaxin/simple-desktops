//
//  Options.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import Foundation

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

        var description: String {
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

    private static let defaultsKey: String = "UserPreferences"

    init() {
        if let data = UserDefaults.standard.value(forKey: Options.defaultsKey) as? Data,
           let options = try? JSONDecoder().decode(Options.self, from: data)
        {
            self = options
        }
    }

    func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(self), forKey: Options.defaultsKey)
    }
}
