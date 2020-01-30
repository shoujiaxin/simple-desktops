//
//  PopoverViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/6.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var refreshButton: RefreshButton!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var setWallpaperButton: NSButton!
    @IBOutlet var downloadButton: NSButton!

    private var wallpaperManager = WallpaperManager()

    override func viewWillLayout() {
        setWallpaperButton.layer?.borderColor = CGColor(gray: 0.5, alpha: 0.4)
        setWallpaperButton.layer?.borderWidth = 1
        setWallpaperButton.layer?.cornerRadius = 4
        setWallpaperButton.layer?.backgroundColor = CGColor(gray: 0.6, alpha: 0.2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.imageScaling = .scaleAxesIndependently

        progressIndicator.appearance = NSAppearance(named: .aqua)
        progressIndicator.isHidden = true

        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: "Set as Wallpaper", attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        set(refreshing: true)
        wallpaperManager.getLastWallpaper { image, error in
            DispatchQueue.main.sync {
                self.set(refreshing: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func downloadButtonClicked(_: Any) {}

    @IBAction func refreshButtonClicked(_: Any) {
        set(refreshing: true)
        wallpaperManager.updatePreview { image, error in
            DispatchQueue.main.sync {
                self.set(refreshing: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func historyButtonClicked(_: Any) {}

    @IBAction func settingsButtonClicked(_: Any) {}

    @IBAction func setWallpaperButtonClicked(_: Any) {
        set(refreshing: true)
        wallpaperManager.setWallpaper { error in
            DispatchQueue.main.sync {
                self.set(refreshing: false)

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }

    private func set(refreshing: Bool) {
        if refreshing {
            refreshButton.isHidden = true
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(nil)
            setWallpaperButton.isEnabled = false
            downloadButton.isEnabled = false
        } else {
            refreshButton.isHidden = false
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(nil)
            setWallpaperButton.isEnabled = true
            downloadButton.isEnabled = true
        }
    }
}
