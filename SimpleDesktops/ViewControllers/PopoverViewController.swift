//
//  PopoverViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/6.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
    @IBOutlet var contentView: NSView!

    enum ViewControllerState {
        case preview
        case history
        case settings
    }

    let previewViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "PreviewViewController") as PreviewViewController
    let historyViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "HistoryViewController") as HistoryViewController
    let settingsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "SettingsViewController") as SettingsViewController

    var currentVCState = ViewControllerState.preview

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(previewViewController)
        addChild(historyViewController)
        addChild(settingsViewController)

        contentView.addSubview(children[0].view)
    }

    @IBAction func historyButtonClicked(_: Any) {
        switch currentVCState {
        case .preview:
            transition(from: children[0], to: children[1], options: .slideLeft, completionHandler: nil)
            currentVCState = .history
        case .history:
            transition(from: children[1], to: children[0], options: .slideRight, completionHandler: nil)
            currentVCState = .preview
        case .settings:
            transition(from: children[2], to: children[1], options: .slideLeft, completionHandler: nil)
            currentVCState = .history
        }
    }

    @IBAction func settingsButtonClicked(_: Any) {
        switch currentVCState {
        case .preview:
            transition(from: children[0], to: children[2], options: .slideUp, completionHandler: nil)
            currentVCState = .settings
        case .history:
            transition(from: children[1], to: children[2], options: .slideUp, completionHandler: nil)
            currentVCState = .settings
        case .settings:
            transition(from: children[2], to: children[0], options: .slideDown, completionHandler: nil)
            currentVCState = .preview
        }
    }
}
