//
//  PreviewViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class PreviewViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var updateButton: UpdateButton!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var setWallpaperButton: PillButton!
    @IBOutlet var downloadButton: NSButton!

    private var wallpaperManager = WallpaperManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.imageScaling = .scaleAxesIndependently

        progressIndicator.appearance = NSAppearance(named: .aqua)
        progressIndicator.isHidden = true

        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: "Set as Wallpaper", attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        set(updating: true)
        wallpaperManager.getLastWallpaper { image, error in
            DispatchQueue.main.sync {
                self.set(updating: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func downloadButtonClicked(_: Any) {
        guard let wallpaperName = wallpaperManager.wallpaperName else {
            return
        }

        set(updating: true)
        var url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        url.appendPathComponent(wallpaperName)
        wallpaperManager.downloadWallpaper(to: url) { error in
            DispatchQueue.main.sync {
                self.set(updating: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }

    @IBAction func updateButtonClicked(_: Any) {
        set(updating: true)
        wallpaperManager.updatePreview { image, error in
            DispatchQueue.main.sync {
                self.set(updating: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func setWallpaperButtonClicked(_: Any) {
        set(updating: true)
        wallpaperManager.setWallpaper { error in
            DispatchQueue.main.sync {
                self.set(updating: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }

    private func set(updating: Bool) {
        if updating {
            updateButton.isHidden = true
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(nil)
            setWallpaperButton.isEnabled = false
            downloadButton.isEnabled = false
        } else {
            updateButton.isHidden = false
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(nil)
            setWallpaperButton.isEnabled = true
            downloadButton.isEnabled = true
        }
    }
}
