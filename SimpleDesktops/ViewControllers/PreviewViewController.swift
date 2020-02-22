//
//  PreviewViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class PreviewViewController: NSViewController {
    @IBOutlet var downloadButton: NSButton!
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var setWallpaperButton: PillButton!
    @IBOutlet var updateButton: UpdateButton!

    public var isUpdating: Bool = false {
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

    private var wallpaperManager: WallpaperManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        wallpaperManager = (parent as! PopoverViewController).wallpaperManager

        progressIndicator.appearance = Utils.currentAppearance()
        progressIndicator.isHidden = true

        setWallpaperButton.attributedTitle = NSMutableAttributedString(string: "Set as Wallpaper", attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

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
        wallpaperManager.image?.previewImage { image, error in
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
        guard let imageName = wallpaperManager.image?.name else {
            return
        }

        let directory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let url = URL(fileURLWithPath: imageName, relativeTo: directory)

        isUpdating = true
        wallpaperManager.image?.download(to: url) { error in
            DispatchQueue.main.sync {
                self.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
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
        isUpdating = true
        wallpaperManager.change { error in
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
        wallpaperManager.update { image, error in
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
}
