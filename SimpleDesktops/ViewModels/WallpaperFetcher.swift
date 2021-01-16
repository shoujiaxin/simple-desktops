//
//  WallpaperFetcher.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SDWebImage
import SwiftSoup
import SwiftUI

class WallpaperFetcher: ObservableObject {
    @Published private(set) var image: NSImage? {
        didSet {
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingProgress = 0
            }
        }
    }

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadingProgress: Double = 0

    @Published private(set) var isDownloading: Bool = false
    @Published private(set) var downloadingProgress: Double = 0

    private var context: NSManagedObjectContext

    private var imageUrl: URL? {
        willSet {
            if let url = newValue {
                fetchImage(from: url)
            }
        }
    }

    init(in context: NSManagedObjectContext) {
        self.context = context

        if let wallpaper = try? context.fetch(Wallpaper.fetchRequest(.all)).first,
           let url = wallpaper.previewUrl
        {
            imageUrl = url
            fetchImage(from: url)
        } else {
            fetchURL()
        }
    }

    func fetchURL() {
        isLoading = true
        loadingProgress = 0

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
                Wallpaper.update(by: url, in: self.context)

                DispatchQueue.main.async {
                    self.imageUrl = url
                }
            }
        }

        task.resume()
    }

    func download(to directory: URL, completionHandler: @escaping (URL?) -> Void = { _ in }) {
        guard let imageUrl = imageUrl,
              let wallpaper = Wallpaper.withPreviewURL(imageUrl, in: context)
        else {
            return
        }

        isDownloading = true
        downloadingProgress = 0

        SDWebImageDownloader.shared.downloadImage(with: wallpaper.url, options: .highPriority) { receivedSize, expectedSize, _ in
            DispatchQueue.main.async {
                self.downloadingProgress = Double(receivedSize) / Double(expectedSize)
            }
        } completed: { _, data, _, _ in
            let url = directory.appendingPathComponent(wallpaper.name ?? wallpaper.id!.uuidString)
            try? data?.write(to: url)

            DispatchQueue.main.async {
                self.isDownloading = false
                self.downloadingProgress = 0
            }

            completionHandler(data == nil ? nil : url)
        }
    }

    func cancelDownload() {
        SDWebImageDownloader.shared.cancelAllDownloads()
    }

    func setWallpaper() {
        guard let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
              let directory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(bundleName)
        else {
            return
        }

        download(to: directory.appendingPathComponent("Wallpapers")) { url in
            if let url = url {
                for screen in NSScreen.screens {
                    try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
            }
        }
    }

    private func fetchImage(from url: URL) {
        SDWebImageManager.shared.loadImage(with: url, options: .highPriority) { receivedSize, expectedSize, _ in
            DispatchQueue.main.async {
                self.loadingProgress = Double(receivedSize) / Double(expectedSize)
            }
        } completed: { image, _, _, _, _, _ in
            if let image = image {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
