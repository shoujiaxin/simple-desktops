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

    private var imageManager: ImageManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.imageScaling = .scaleAxesIndependently

        imageManager = ImageManager()
        imageManager.getLastPreviewImage { image, error in
            DispatchQueue.main.sync {
                if let error = error {
                    Utils.showCriticalAlert(withInformation: String(describing: error))
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func refreshButtonClicked(_: RefreshButton) {
        imageManager.getNewPreviewImage { image, error in
            DispatchQueue.main.sync {
                if let error = error {
                    Utils.showCriticalAlert(withInformation: String(describing: error))
                    return
                }

                self.imageView.image = image
            }
        }
    }

    @IBAction func historyButtonClicked(_: Any) {}

    @IBAction func settingsButtonClicked(_: Any) {}
}
