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

    public var isUpdating: Bool = false {
        willSet {
            if newValue {
                updateButton.isHidden = true
                imageView.sd_imageIndicator?.startAnimatingIndicator()
                setWallpaperButton.isEnabled = false
                downloadButton.isEnabled = false
            } else {
                updateButton.isHidden = false
                imageView.sd_imageIndicator?.stopAnimatingIndicator()
                setWallpaperButton.isEnabled = true
                downloadButton.isEnabled = true
            }
        }
    }

    private var wallpaperManager: WallpaperManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: NSLocalizedString("Set as Wallpaper", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        wallpaperManager = (parent as! PopoverViewController).wallpaperManager
        if Options.shared.changePicture {
            wallpaperManager.change(every: Options.shared.changeInterval.seconds)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if isUpdating {
            return
        }

        isUpdating = true
        imageView.sd_setImage(with: wallpaperManager.image?.previewUrl, placeholderImage: nil, options: .highPriority) { _, error, _, _ in
            self.isUpdating = false

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

        isUpdating = true
        SDWebImageDownloader.shared.downloadImage(with: wallpaperManager.image?.fullUrl, options: .highPriority, progress: nil) { _, data, error, _ in
            self.isUpdating = false

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
        isUpdating = true
        wallpaperManager.change { error in
            self.isUpdating = false

            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }
        }
    }

    @IBAction func updateButtonClicked(_: Any) {
        isUpdating = true
        wallpaperManager.update { image, error in
            if let error = error {
                self.isUpdating = false
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }

            self.wallpaperManager.image = image
            self.imageView.sd_setImage(with: image?.previewUrl, placeholderImage: self.imageView.image, options: .highPriority) { _, error, _, _ in
                self.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }
}
