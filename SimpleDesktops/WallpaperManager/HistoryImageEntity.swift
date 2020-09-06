//
//  HistoryImageEntity.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/5/23.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Foundation

class HistoryImageEntity {
    class EntityProperty {
        var fullUrl: String = "fullUrl"
        var name: String = "name"
        var previewUrl: String = "previewUrl"
        var timeStamp: String = "timeStamp"
    }

    var name: String = ""
    var property = EntityProperty()

    init(name: String) {
        self.name = name
    }
}
