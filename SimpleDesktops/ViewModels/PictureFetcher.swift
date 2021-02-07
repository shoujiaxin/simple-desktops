//
//  PictureFetcher.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/9.
//

import Combine
import CoreData
import SDWebImage

class PictureFetcher: ObservableObject {
    @Published var isFetching: Bool = false
    @Published var fetchingProgress: Double = 0

    @Published private(set) var isDownloading: Bool = false
    @Published private(set) var downloadingProgress: Double = 0

    private let context: NSManagedObjectContext

    private var fetchCancellable: AnyCancellable?

    init(context: NSManagedObjectContext) {
        self.context = context

        // Launch this app for the first time
        if let pictures = try? context.fetch(Picture.fetchRequest(nil)),
           pictures.isEmpty
        {
            fetch()
        }
    }

    func cancelDownload() {
        SDWebImageDownloader.shared.cancelAllDownloads()
    }

    func download(_ picture: Picture,
                  to directory: URL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
                  completed: @escaping (URL) -> Void = { _ in })
    {
        isDownloading = true
        let url = directory.appendingPathComponent(picture.name ?? picture.id.uuidString)
        guard !FileManager.default.fileExists(atPath: url.path) else {
            isDownloading = false
            completed(url)
            return
        }

        SDWebImageDownloader.shared.downloadImage(with: picture.url, options: .highPriority) { receivedSize, expectedSize, _ in
            DispatchQueue.main.async {
                self.downloadingProgress = Double(receivedSize) / Double(expectedSize)
            }
        } completed: { _, data, _, _ in
            try? data?.write(to: url)
            self.isDownloading = false
            completed(url)
        }
    }

    func fetch(completed: @escaping (Picture) -> Void = { _ in }) {
        isFetching = true
        fetchCancellable?.cancel()
        fetchCancellable = SimpleDesktopsRequest.shared.randomPicturePublisher
            .sink(receiveCompletion: { _ in
                // TODO: error handle
            }) { info in
                if let info = info {
                    completed(Picture.update(from: info, in: self.context))
                    // `isFetching` is set to `false` in `PreviewView` after the picture is loaded
                } else {
                    self.isFetching = false
                }
            }
    }
}
