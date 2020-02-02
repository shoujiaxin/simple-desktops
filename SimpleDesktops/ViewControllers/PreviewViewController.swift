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

    var wallpaperManager = WallpaperManager()

    var isUpdating: Bool = false {
        willSet {
            if newValue {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        progressIndicator.appearance = NSAppearance(named: .aqua)
        progressIndicator.isHidden = true

        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: "Set as Wallpaper", attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        if Options.shared.changePicture {
            wallpaperManager.changeWallpaper(every: Options.shared.changeInterval.seconds)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if isUpdating {
            return
        }

        isUpdating = true
        wallpaperManager.getLatestPreview { image, error in
            DispatchQueue.main.sync {
                self.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func downloadButtonClicked(_: Any) {
        let directory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]

        isUpdating = true
        wallpaperManager.downloadWallpaper(to: directory) { error in
            DispatchQueue.main.sync {
                self.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }

    @IBAction func updateButtonClicked(_: Any) {
        isUpdating = true
        wallpaperManager.updatePreview { image, error in
            DispatchQueue.main.sync {
                self.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func setWallpaperButtonClicked(_: Any) {
        isUpdating = true
        wallpaperManager.changeWallpaper { error in
            DispatchQueue.main.sync {
                self.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }
}
