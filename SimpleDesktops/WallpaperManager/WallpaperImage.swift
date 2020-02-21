//
//  WallpaperImage.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/2/20.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

protocol WallpaperImage {
    var fullLink: String? { get set }

    var name: String? { get set }

    var previewLink: String? { get set }

    func download(to: URL, completionHandler: @escaping (Error?) -> Void)

    func fullImage(completionHandler: @escaping (NSImage?, Error?) -> Void)

    func previewImage(completionHandler: @escaping (NSImage?, Error?) -> Void)
}
