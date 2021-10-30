//
//  ChangeInterval.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/3/8.
//

import Foundation

enum ChangeInterval: String, CaseIterable, Identifiable, Codable {
    case whenWakingFromSleep = "When waking from sleep"
    case everyMinute = "Every minute"
    case everyFiveMinutes = "Every 5 minutes"
    case everyFifteenMinutes = "Every 15 minutes"
    case everyThirtyMinutes = "Every 30 minutes"
    case everyHour = "Every hour"
    case everyDay = "Every day"

    var id: String {
        return rawValue
    }

    var seconds: TimeInterval? {
        switch self {
        case .whenWakingFromSleep: return nil
        case .everyMinute: return 60
        case .everyFiveMinutes: return 5 * 60
        case .everyFifteenMinutes: return 15 * 60
        case .everyThirtyMinutes: return 30 * 60
        case .everyHour: return 60 * 60
        case .everyDay: return 24 * 60 * 60
        }
    }

    static var timeChangeIntervals: [Self] {
        allCases.filter { $0.seconds != nil }
    }

    static var eventChangeIntervals: [Self] {
        allCases.filter { $0.seconds == nil }
    }
}
