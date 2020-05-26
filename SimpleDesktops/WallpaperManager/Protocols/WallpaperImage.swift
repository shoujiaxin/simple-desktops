//
//  WallpaperImage.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/2/20.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

protocol WallpaperImage {
    var fullUrl: URL? { get set }

    var name: String? { get set }

    var previewUrl: URL? { get set }

    func download(to: URL, completionHandler: @escaping (Error?) -> Void)

    func fullImage(completionHandler: @escaping (NSImage?, Error?) -> Void)

    func previewImage(completionHandler: @escaping (NSImage?, Error?) -> Void)
}
