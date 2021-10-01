//
//  PictureFetcher.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/2/9.
//

import Combine
import CoreData
import Kingfisher

class PictureFetcher: ObservableObject {
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
        KingfisherManager.shared.downloader.cancelAll()
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

        KingfisherManager.shared.retrieveImage(with: picture.url, options: nil) { [weak self] receivedSize, totalSize in
            assert(Thread.isMainThread)
            self?.downloadingProgress = Double(receivedSize) / Double(totalSize)
        } completionHandler: { [weak self] result in
            self?.isDownloading = false
            switch result {
            case let .failure(error):
                print(error) // TODO: Log
            case let .success(imageResult):
                try? imageResult.image.tiffRepresentation?.write(to: url)
                completed?(url)
            }
        }
    }

    func fetch(completed: ((Picture) -> Void)? = nil) {
        isFetching = true
        fetchCancellable?.cancel()
        fetchCancellable = SimpleDesktopsRequest.shared.randomPicture
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.isFetching = false
                    print(error) // TODO: Log
                case .finished:
                    print("finished") // TODO: Log
                }
            } receiveValue: { [weak self] info in
                // Pre-load the preview image
                KingfisherManager.shared.retrieveImage(with: info.previewURL, options: nil) { receivedSize, totalSize in
                    assert(Thread.isMainThread)
                    self?.fetchingProgress = Double(receivedSize) / Double(totalSize)
                } completionHandler: { result in
                    self?.isFetching = false
                    switch result {
                    case let .failure(error):
                        print(error) // TODO: Log
                    case .success:
                        if let context = self?.context {
                            let picture = Picture.update(from: info, in: context)
                            completed?(picture)
                        }
                    }
                }
            }
    }
}
