//
//  PreviewViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import SDWebImage

class PreviewViewController: NSViewController {
    @IBOutlet var downloadButton: NSButton!
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var setWallpaperButton: PillButton!
    @IBOutlet var updateButton: UpdateButton!

    public weak var progressIndicator: NSProgressIndicator!
    public var loadingTaskCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: NSLocalizedString("Set as Wallpaper", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        progressIndicator = imageView.sd_imageIndicator!.indicatorView as? NSProgressIndicator
        progressIndicator.isIndeterminate = false

        if Options.shared.changePicture {
            WallpaperManager.shared.change(every: Options.shared.changeInterval.seconds)
        }

        if let image = WallpaperManager.shared.image {
            updatePreview(with: image)
        }
    }

    @IBAction func downloadButtonClicked(_: Any) {
        guard let image = WallpaperManager.shared.image, let imageName = image.name else {
            return
        }

        let directory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]

        startLoading(self)
        SDWebImageDownloader.shared.downloadImage(with: image.fullUrl, options: .highPriority, progress: { receivedSize, expectedSize, _ in
            self.loadingProgress(at: Double(receivedSize) / Double(expectedSize))
        }) { image, data, error, _ in
            self.stopLoading(self)

            if let error = error {
                Utils.showNotification(withTitle: NSLocalizedString("Failed to Download Wallpaper", comment: ""), information: error.localizedDescription, contentImage: NSImage(named: NSImage.cautionName))
                return
            }

            do {
                try data?.write(to: directory.appendingPathComponent(imageName))
                Utils.showNotification(withTitle: NSLocalizedString("Wallpaper Downloaded", comment: ""), information: imageName, contentImage: image)
            } catch {
                Utils.showNotification(withTitle: NSLocalizedString("Failed to Download Wallpaper", comment: ""), information: error.localizedDescription, contentImage: NSImage(named: NSImage.cautionName))
            }
        }
    }

    @IBAction func historyButtonClicked(_: Any) {
        let parentViewController = parent as! PopoverViewController
        parentViewController.transition(to: .history)
    }

    @IBAction func preferencesButtonClicked(_: Any) {
        let parentViewController = parent as! PopoverViewController
        parentViewController.transition(to: .preferences)
    }

    @IBAction func setWallpaperButtonClicked(_: Any) {
        WallpaperManager.shared.change { _ in
        }
    }

    @IBAction func updateButtonClicked(_: Any) {
        WallpaperManager.shared.update { error in
            if let error = error {
                Utils.showNotification(withTitle: NSLocalizedString("Failed to Load Wallpaper", comment: ""), information: error.localizedDescription, contentImage: NSImage(named: NSImage.cautionName))
                return
            }
        }
    }
}

// MARK: WallpaperManagerDelegate

extension PreviewViewController: WallpaperManagerDelegate {
    func loadingProgress(at percent: Double) {
        DispatchQueue.main.async {
            self.progressIndicator.increment(by: percent * self.progressIndicator.maxValue - self.progressIndicator.doubleValue)
        }
    }

    func startLoading(_: Any?) {
        loadingTaskCount += 1

        DispatchQueue.main.async {
            self.progressIndicator.doubleValue = 0

            self.downloadButton.isEnabled = false
            self.imageView.sd_imageIndicator?.startAnimatingIndicator()
            self.setWallpaperButton.isEnabled = false
            self.updateButton.isHidden = true
        }
    }

    func stopLoading(_: Any?) {
        loadingTaskCount -= 1
        if loadingTaskCount > 0 {
            return
        } else if loadingTaskCount < 0 {
            loadingTaskCount = 0
        }

        DispatchQueue.main.async {
            self.downloadButton.isEnabled = true
            self.imageView.sd_imageIndicator?.stopAnimatingIndicator()
            self.setWallpaperButton.isEnabled = true
            self.updateButton.isHidden = false
        }
    }

    func updatePreview(with image: WallpaperImage) {
        startLoading(self)
        imageView.sd_setImage(with: image.previewUrl, placeholderImage: imageView.image, options: .highPriority, progress: { receivedSize, expectedSize, _ in
            self.loadingProgress(at: Double(receivedSize) / Double(expectedSize))
        }) { _, error, _, _ in
            self.stopLoading(self)

            if let error = error {
                Utils.showNotification(withTitle: NSLocalizedString("Failed to Load Wallpaper", comment: ""), information: error.localizedDescription, contentImage: NSImage(named: NSImage.cautionName))
                return
            }
        }
    }
}
