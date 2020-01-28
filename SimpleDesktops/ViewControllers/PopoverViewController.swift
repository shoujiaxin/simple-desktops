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

    private var imageManager: ImageManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.imageScaling = .scaleAxesIndependently

        progressIndicator.appearance = NSAppearance(named: .aqua)
        progressIndicator.isHidden = true

        imageManager = ImageManager()
        set(refreshing: true)
        imageManager.getLastPreviewImage { image, error in
            DispatchQueue.main.sync {
                if let error = error {
                    Utils.showCriticalAlert(withInformation: String(describing: error))
                    return
                }

                self.imageView.image = image
                self.set(refreshing: false)
            }
        }
    }

    @IBAction func refreshButtonClicked(_: Any) {
        set(refreshing: true)
        imageManager.getNewPreviewImage { image, error in
            DispatchQueue.main.sync {
                if let error = error {
                    Utils.showCriticalAlert(withInformation: String(describing: error))
                    return
                }

                self.imageView.image = image
                self.set(refreshing: false)
            }
        }
    }

    @IBAction func historyButtonClicked(_: Any) {}

    @IBAction func settingsButtonClicked(_: Any) {}

    private func set(refreshing: Bool) {
        if refreshing {
            refreshButton.isHidden = true
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(nil)
        } else {
            refreshButton.isHidden = false
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(nil)
        }
    }
}
