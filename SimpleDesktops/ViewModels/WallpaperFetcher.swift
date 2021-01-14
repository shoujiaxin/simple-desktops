//
//  WallpaperFetcher.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SwiftSoup
import SwiftUI

class WallpaperFetcher: ObservableObject {
    @Published private(set) var imageUrl: URL?

    private var context: NSManagedObjectContext

    init(in context: NSManagedObjectContext) {
        self.context = context

        if let wallpaper = try? context.fetch(Wallpaper.fetchRequest(.all)).first {
            imageUrl = wallpaper.previewUrl
        } else {
            fetchURL() // TODO: isLoading = true
        }
    }

    func fetchURL() {
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
}
