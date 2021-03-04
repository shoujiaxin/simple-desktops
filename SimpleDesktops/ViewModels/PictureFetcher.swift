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
    @Published private(set) var image: NSImage?

    @Published private(set) var isFetching: Bool = false {
        willSet {
            if isFetching != newValue {
                fetchingProgress = 0
            }
        }
    }

    @Published private(set) var fetchingProgress: Double = 0

    @Published private(set) var isDownloading: Bool = false {
        willSet {
            if isDownloading != newValue {
                downloadingProgress = 0
            }
        }
    }

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
                  completed: ((URL) -> Void)? = nil)
    {
        isDownloading = true
        let url = directory.appendingPathComponent(picture.name ?? picture.id.uuidString)
        guard !FileManager.default.fileExists(atPath: url.path) else {
            isDownloading = false
            completed?(url)
            return
        }

        SDWebImageDownloader.shared.downloadImage(with: picture.url, options: .highPriority) { receivedSize, expectedSize, _ in
            DispatchQueue.main.async {
                self.downloadingProgress = Double(receivedSize) / Double(expectedSize)
            }
        } completed: { _, data, error, finished in
            self.isDownloading = !finished

            if error == nil {
                try? data?.write(to: url)
                completed?(url)
            }
        }
    }

    func fetch(completed: ((Picture) -> Void)? = nil) {
        isFetching = true
        fetchCancellable?.cancel()
        fetchCancellable = SimpleDesktopsRequest.shared.randomPicturePublisher
            .sink(receiveCompletion: { _ in
                // TODO: error handle
            }) { info in
                if let info = info {
                    let picture = Picture.update(from: info, in: self.context)

                    // Prefetch the preview image
                    SDWebImageManager.shared.loadImage(with: picture.previewURL, options: .highPriority) { receivedSize, expectedSize, _ in
                        DispatchQueue.main.async {
                            self.fetchingProgress = Double(receivedSize) / Double(expectedSize)
                        }
                    } completed: { image, _, _, _, finished, _ in
                        self.image = image
                        self.isFetching = !finished
                    }

                    completed?(picture)
                } else {
                    self.isFetching = false
                }
            }
    }
}
