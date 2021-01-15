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
            }
        }
    }

    @Published private(set) var isLoading: Bool = false

    @Published private(set) var loadingProgress: Double = 0

    private var context: NSManagedObjectContext

    private var loadingProgressObservation: NSKeyValueObservation?

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

    func download() {
        guard let directory = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
              let imageUrl = imageUrl,
              let wallpaper = Wallpaper.withPreviewURL(imageUrl, in: context)
        else {
            return
        }

        SDWebImageDownloader.shared.downloadImage(with: wallpaper.url, options: .highPriority) { receivedSize, expectedSize, _ in
            print(Double(receivedSize / expectedSize))
            // TODO: downloading progress
        } completed: { _, data, _, _ in
            try? data?.write(to: directory.appendingPathComponent(wallpaper.name ?? wallpaper.id!.uuidString))
            // TODO: send notification
        }
    }

    private func fetchImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }

            DispatchQueue.main.async {
                self.image = NSImage(data: data)
            }
        }

        loadingProgressObservation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.loadingProgress = progress.fractionCompleted
            }
        }

        task.resume()
    }
}
