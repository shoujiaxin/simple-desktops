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

    public var isLoading: Bool = false {
        willSet {
            if newValue {
                downloadButton.isEnabled = false
                imageView.sd_imageIndicator?.startAnimatingIndicator()
                setWallpaperButton.isEnabled = false
                updateButton.isHidden = true

                progressIndicator.doubleValue = 0
            } else {
                downloadButton.isEnabled = true
                imageView.sd_imageIndicator?.stopAnimatingIndicator()
                setWallpaperButton.isEnabled = true
                updateButton.isHidden = false
            }
        }
    }

    private weak var wallpaperManager: WallpaperManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: NSLocalizedString("Set as Wallpaper", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        progressIndicator = imageView.sd_imageIndicator!.indicatorView as? NSProgressIndicator
        progressIndicator.isIndeterminate = false

        wallpaperManager = (parent as! PopoverViewController).wallpaperManager
        if Options.shared.changePicture {
            wallpaperManager.change(every: Options.shared.changeInterval.seconds)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if isLoading {
            return
        }

        isLoading = true
        imageView.sd_setImage(with: wallpaperManager.image?.previewUrl, placeholderImage: nil, options: .highPriority, progress: { receivedSize, expectedSize, _ in
            DispatchQueue.main.sync {
                self.progressIndicator.increment(by: Double(receivedSize) / Double(expectedSize) * self.progressIndicator.maxValue - self.progressIndicator.doubleValue)
            }
        }) { _, error, _, _ in
            self.isLoading = false

            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }
        }
    }

    @IBAction func downloadButtonClicked(_: Any) {
        guard let imageName = wallpaperManager.image?.name else {
            return
        }

        let directory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]

        isLoading = true
        SDWebImageDownloader.shared.downloadImage(with: wallpaperManager.image?.fullUrl, options: .highPriority, progress: { receivedSize, expectedSize, _ in
            DispatchQueue.main.sync {
                self.progressIndicator.increment(by: Double(receivedSize) / Double(expectedSize) * self.progressIndicator.maxValue - self.progressIndicator.doubleValue)
            }
        }) { _, data, error, _ in
            self.isLoading = false

            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }

            try? data?.write(to: directory.appendingPathComponent(imageName))
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
        progressIndicator.isIndeterminate = true
        isLoading = true
        wallpaperManager.change { error in
            self.progressIndicator.isIndeterminate = false
            self.isLoading = false

            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }
        }
    }

    @IBAction func updateButtonClicked(_: Any) {
        progressIndicator.isIndeterminate = true
        isLoading = true
        wallpaperManager.update { image, error in
            self.progressIndicator.isIndeterminate = false
            if let error = error {
                self.isLoading = false
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }

            self.wallpaperManager.image = image
            self.imageView.sd_setImage(with: image?.previewUrl, placeholderImage: self.imageView.image, options: .highPriority, progress: { receivedSize, expectedSize, _ in
                DispatchQueue.main.sync {
                    self.progressIndicator.increment(by: Double(receivedSize) / Double(expectedSize) * self.progressIndicator.maxValue - self.progressIndicator.doubleValue)
                }
            }) { _, error, _, _ in
                self.isLoading = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }
}
