//
//  WallpaperFetcher.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import Combine
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

    private var context: NSManagedObjectContext

    private var fetchImageCancellable: AnyCancellable?

    private var imageUrl: URL? {
        willSet {
            if let url = newValue {
                fetchImageCancellable?.cancel()
                fetchImageCancellable = fetchImageCancellable(for: url)
            }
        }
    }

    init(in context: NSManagedObjectContext) {
        self.context = context

        if let wallpaper = try? context.fetch(Wallpaper.fetchRequest(.all)).first,
           let url = wallpaper.previewUrl
        {
            imageUrl = url
            fetchImageCancellable = fetchImageCancellable(for: url)
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

    private func fetchImageCancellable(for url: URL) -> AnyCancellable? {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in NSImage(data: data) }
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .assign(to: \.image, on: self)
    }
}
