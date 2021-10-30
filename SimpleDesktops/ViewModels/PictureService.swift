//
//  PictureService.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/10/31.
//

import AppKit
import Kingfisher
import Logging

class PictureService: ObservableObject {
    @Published private(set) var previewImage: NSImage? = nil

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

    private let logger = Logger(for: PictureService.self)

    init(context: NSManagedObjectContext) {
        self.context = context

        if let url = try? context.fetch(Picture.fetchRequest(nil)).first?.previewURL {
            KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString) { [weak self] result in
                if case .success(let imageResult) = result {
                    self?.previewImage = imageResult.image
                }
            }
        } else {
            Task {
                await fetch()
            }
        }
    }

    @MainActor func fetch() async {
        isFetching = true
        defer { isFetching = false }

        do {
            let info = try await SimpleDesktopsRequest.shared.random()
            fetchingProgress = 0.3

            let (bytes, response) = try await URLSession.shared.bytes(from: info.previewURL)
            let length = Int(response.expectedContentLength)
            var data = Data(capacity: length)
            for try await byte in bytes {
                data.append(byte)
                fetchingProgress = 0.3 + 0.7 * Double(data.count) / Double(length)
            }

            if let image = NSImage(data: data) {
                previewImage = image
                KingfisherManager.shared.cache.store(image, forKey: info.previewURL.absoluteString)
            }

            Picture.update(with: info, in: context)
        } catch {
            logger.error("Failed to fetch picture, \(error.localizedDescription)")
        }
    }

    func download(_ picture: Picture,
                  to destination: URL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
                  completed: ((URL) -> Void)? = nil)
    {
        isDownloading = true

        let url = destination.appendingPathComponent(picture.name ?? picture.id.uuidString)
        guard !FileManager.default.fileExists(atPath: url.path) else {
            isDownloading = false
            completed?(url)
            logger.info("Picture is already downloaded")
            return
        }

        KingfisherManager.shared.downloader.downloadImage(with: picture.url, options: nil) { [weak self] receivedSize, totalSize in
            self?.downloadingProgress = Double(receivedSize) / Double(totalSize)
        } completionHandler: { [weak self] result in
            self?.isDownloading = false
            switch result {
            case .failure(let error):
                self?.logger.error("Failed to download picture, \(error.localizedDescription)")
            case .success(let imageResult):
                guard let data = imageResult.image.tiffRepresentation else {
                    return
                }

                do {
                    try data.write(to: url)
                    completed?(url)
                    self?.logger.info("Picture downloaded to \(url.path)")
                } catch {
                    self?.logger.error("Failed to save picture, \(error.localizedDescription)")
                }
            }
        }
    }

    func cancelDownload() {
        KingfisherManager.shared.downloader.cancelAll()
    }
}
