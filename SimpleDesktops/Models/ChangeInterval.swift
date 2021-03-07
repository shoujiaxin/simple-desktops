//
//  ChangeInterval.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/3/8.
//

import SwiftUI

enum ChangeInterval: Int, CaseIterable, Identifiable, Codable {
    case whenWakingFromSleep = -1
    case everyMinute
    case everyFiveMinutes
    case everyFifteenMinutes
    case everyThirtyMinutes
    case everyHour
    case everyDay

    var description: LocalizedStringKey {
        switch self {
        case .whenWakingFromSleep: return "When waking from sleep"
        case .everyMinute: return "Every minute"
        case .everyFiveMinutes: return "Every 5 minutes"
        case .everyFifteenMinutes: return "Every 15 minutes"
        case .everyThirtyMinutes: return "Every 30 minutes"
        case .everyHour: return "Every hour"
        case .everyDay: return "Every day"
        }
    }

    var id: Int {
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
}
