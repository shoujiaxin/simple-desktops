//
//  Options.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/16.
//

import SwiftUI

struct Options: Codable {
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
