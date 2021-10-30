//
//  Logger.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/10/30.
//

import Foundation
import Logging

extension Logger {
    init<T>(for type: T.Type) {
        self.init(label: "\(Bundle.main.bundleIdentifier!).\(type)")
    }
}
