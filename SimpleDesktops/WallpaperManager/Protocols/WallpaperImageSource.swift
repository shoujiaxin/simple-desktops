//
//  WallpaperImageSource.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/2/22.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

protocol WallpaperImageSource {
    var entity: HistoryImageEntity { get }

    var images: [WallpaperImage] { get set }

    func removeImage(at index: Int) -> WallpaperImage

    func updateImage() -> Bool
}
