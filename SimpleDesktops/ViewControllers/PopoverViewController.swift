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
        case preferences
    }

    let previewViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "PreviewViewController") as PreviewViewController
    let historyViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "HistoryViewController") as HistoryViewController
    let preferencesViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "PreferencesViewController") as PreferencesViewController

    var currentVCState = ViewControllerState.preview

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(previewViewController)
        addChild(historyViewController)
        addChild(preferencesViewController)

        contentView.addSubview(children[0].view)
    }

    @IBAction func historyButtonClicked(_: Any) {
        switch currentVCState {
        case .preview:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.history.rawValue], options: .slideLeft, completionHandler: nil)

            currentVCState = .history
        case .history:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.preview.rawValue], options: .slideRight, completionHandler: nil)

            currentVCState = .preview
        case .preferences:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.history.rawValue], options: .slideLeft, completionHandler: nil)
            let appDelegate = NSApp.delegate as! AppDelegate
            appDelegate.popover.contentSize = NSSize(width: 400, height: 348)

            currentVCState = .history
        }
    }

    @IBAction func preferencesButtonClicked(_: Any) {
        let appDelegate = NSApp.delegate as! AppDelegate

        switch currentVCState {
        case .preferences:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.preview.rawValue], options: .slideDown, completionHandler: nil)
            appDelegate.popover.contentSize = NSSize(width: 400, height: 348)

            currentVCState = .preview
        default:
            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.preferences.rawValue], options: .slideUp, completionHandler: nil)
            appDelegate.popover.contentSize = NSSize(width: 400, height: 126)

            currentVCState = .preferences
        }
    }
}
