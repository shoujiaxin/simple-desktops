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

    enum ViewControllerState: Int {
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
        case .history:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.preview.rawValue], options: .slideRight, completionHandler: nil)
            currentVCState = .preview
        default:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.history.rawValue], options: .slideLeft, completionHandler: nil)
            currentVCState = .history
        }
    }

    @IBAction func settingsButtonClicked(_: Any) {
        switch currentVCState {
        case .settings:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.preview.rawValue], options: .slideDown, completionHandler: nil)
            currentVCState = .preview
        default:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.settings.rawValue], options: .slideUp, completionHandler: nil)
            currentVCState = .settings
        }
    }
}
