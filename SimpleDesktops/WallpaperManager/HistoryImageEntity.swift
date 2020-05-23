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
        var fullLink: String = "fullLink"
        var name: String = "name"
        var previewLink: String = "previewLink"
        var timeStamp: String = "timeStamp"
    }

    var name: String = ""
    var property: EntityProperty = EntityProperty()

    init(name: String) {
        self.name = name
    }
}
