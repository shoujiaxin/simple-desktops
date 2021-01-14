//
//  Wallpaper.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import CoreData
import Foundation

extension Wallpaper {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Wallpaper> {
        let request = NSFetchRequest<Wallpaper>(entityName: "Wallpaper")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "updateTime", ascending: false)]
        return request
    }
}

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
}
