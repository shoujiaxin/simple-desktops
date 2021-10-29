//
//  Options.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import Foundation
import Logging

struct Options: Codable {
    /// Whether to change wallpaper automatically, default is true.
    var autoChange: Bool = true

    /// Time interval for automatic wallpaper change.
    var changeInterval: ChangeInterval = .everyHour

    private static let logger = Logger(label: "\(Bundle.main.bundleIdentifier!).Options")

    /// Load options from [UserDefaults](https://developer.apple.com/documentation/foundation/preferences). If there is no data, use the default value.
    /// - Parameter userDefaults: UserDefaults object, default is [UserDefaults.standard](https://developer.apple.com/documentation/foundation/userdefaults).
    init(from userDefaults: UserDefaults = .standard) {
        let keys = Mirror(reflecting: self).children.compactMap { $0.label }
        do {
            let data = try JSONSerialization.data(withJSONObject: userDefaults.dictionaryWithValues(forKeys: keys), options: .fragmentsAllowed)
            self = try JSONDecoder().decode(Options.self, from: data)
            Self.logger.info("Options loaded")
        } catch {
            Self.logger.info("No options data found, use default value")
        }
    }

    /// Save current options to UserDefaults.
    /// - Parameter userDefaults: UserDefaults object, default is [UserDefaults.standard](https://developer.apple.com/documentation/foundation/userdefaults).
    func save(to userDefaults: UserDefaults = .standard) {
        do {
            let data = try JSONEncoder().encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                userDefaults.setValuesForKeys(dictionary)
                Self.logger.info("Options saved")
            }
        } catch {
            Self.logger.error("Failed to save options, \(error.localizedDescription)")
        }
    }
}
