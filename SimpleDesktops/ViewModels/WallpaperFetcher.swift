//
//  WallpaperFetcher.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import Foundation
import SDWebImage
import SwiftSoup

class WallpaperFetcher: ObservableObject {
    @Published private(set) var image: NSImage? {
        didSet {
            isLoading = false
        }
    }

    @Published private(set) var isLoading: Bool = false {
        willSet {
            if isLoading != newValue {
                loadingProgress = 0
            }
        }
    }

    @Published private(set) var loadingProgress: Double = 0

    @Published private(set) var isDownloading: Bool = false {
        willSet {
            if isDownloading != newValue {
                downloadingProgress = 0
            }
        }
    }

    @Published private(set) var downloadingProgress: Double = 0

    private var context: NSManagedObjectContext

    private var wallpaper: Wallpaper? {
        didSet {
            fetchPreviewImage()
        }
    }

    init(in context: NSManagedObjectContext) {
        self.context = context

        if let wallpaper = try? context.fetch(Wallpaper.fetchRequest(nil)).first {
            self.wallpaper = wallpaper
            fetchPreviewImage()
        } else {
            fetchURL()
        }
    }

    func fetchURL() {
        isLoading = true

        var links: [String] = []
        let page = Int.random(in: 1 ... 51)
        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")! // TODO: update max page
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                return
            }

            if let doc = try? SwiftSoup.parse(String(data: data!, encoding: .utf8)!), let imgTags = try? doc.select("img") {
                for tag in imgTags {
                    try? links.append(tag.attr("src"))
                }
            }

            if let link = links.randomElement(), let url = URL(string: link) {
                self.wallpaper = Wallpaper.withPreviewURL(url, in: self.context)
            }
        }

        task.resume()
    }

    func download(_ wallpaper: Wallpaper, to directory: URL, completionHandler: @escaping (URL?) -> Void = { _ in }) {
        isDownloading = true

        SDWebImageDownloader.shared.downloadImage(with: wallpaper.url, options: .highPriority) { receivedSize, expectedSize, _ in
            DispatchQueue.main.async {
                self.downloadingProgress = Double(receivedSize) / Double(expectedSize)
            }
        } completed: { _, data, _, _ in
            let url = directory.appendingPathComponent(wallpaper.name ?? wallpaper.id!.uuidString)
            try? data?.write(to: url)

            self.isDownloading = false

            completionHandler(data == nil ? nil : url)
        }
    }

    func download(to directory: URL, completionHandler: @escaping (URL?) -> Void = { _ in }) {
        guard let wallpaper = self.wallpaper else {
            return
        }
        download(wallpaper, to: directory, completionHandler: completionHandler)
    }

    func cancelDownload() {
        SDWebImageDownloader.shared.cancelAllDownloads()
    }

    func setWallpaper(_ wallpaper: Wallpaper) {
        guard let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
              let directory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(bundleName)
        else {
            return
        }

        download(wallpaper, to: directory.appendingPathComponent("Wallpapers")) { url in
            if let url = url {
                for screen in NSScreen.screens {
                    try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
            }
        }
    }

    func setWallpaper() {
        guard let wallpaper = self.wallpaper else {
            return
        }
        setWallpaper(wallpaper)
    }

    func selectWallpaper(_ wallpaper: Wallpaper) {
        self.wallpaper = wallpaper
    }

    func deleteWallpaper(_ wallpaper: Wallpaper) {
        context.delete(wallpaper)
        try? context.save()
    }

    private func fetchPreviewImage() {
        guard let url = wallpaper?.previewUrl else {
            return
        }

        SDWebImageManager.shared.loadImage(with: url, options: .highPriority) { receivedSize, expectedSize, _ in
            DispatchQueue.main.async {
                self.loadingProgress = Double(receivedSize) / Double(expectedSize)
            }
        } completed: { image, _, _, _, _, _ in
            self.image = image
        }
    }
}
