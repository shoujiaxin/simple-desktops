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

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.imageScaling = .scaleAxesIndependently
    }

    @IBAction func refreshButtonClicked(_: RefreshButton) {}

    @IBAction func historyButtonClicked(_: Any) {}

    @IBAction func settingsButtonClicked(_: Any) {}
}
