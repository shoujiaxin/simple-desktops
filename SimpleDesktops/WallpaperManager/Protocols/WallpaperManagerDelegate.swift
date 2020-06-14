//
//  WallpaperManagerDelegate.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2020/6/14.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Foundation

protocol WallpaperManagerDelegate: AnyObject {
    func loadingProgress(at percent: Double)

    func startLoading(_ sender: Any?)

    func stopLoading(_ sender: Any?)

    func updatePreview(with image: WallpaperImage)
}

extension WallpaperManagerDelegate {
    func loadingProgress(at _: Double) {}
}
