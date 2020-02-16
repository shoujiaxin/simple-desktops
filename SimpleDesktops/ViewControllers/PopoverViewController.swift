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
        case history
        case preferences
        case preview
    }

    let historyViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "HistoryViewController") as HistoryViewController
    let preferencesViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "PreferencesViewController") as PreferencesViewController
    let previewViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "PreviewViewController") as PreviewViewController

    var currentVCState = ViewControllerState.preview

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(historyViewController)
        addChild(preferencesViewController)
        addChild(previewViewController)

        contentView.addSubview(children[currentVCState.rawValue].view)
    }

//    override func viewWillAppear() {
//        super.viewWillAppear()
//
//        if currentVCState != .preview {
//            transition(from: children[currentVCState.rawValue], to: children[ViewControllerState.preview.rawValue], options: .allowUserInteraction, completionHandler: nil)
//            let appDelegate = NSApp.delegate as! AppDelegate
//            appDelegate.popover.contentSize = NSSize(width: 400, height: 348)
//
//            currentVCState = .preview
//        }
//    }

    func transition(to targetVCState: ViewControllerState) {
        if currentVCState == targetVCState {
            return
        }

        var transitionOptions: NSViewController.TransitionOptions = .allowUserInteraction
        var viewSize: NSSize?

        switch targetVCState {
        case .history:
            transitionOptions = .slideLeft
        case .preferences:
            transitionOptions = .slideUp
            viewSize = NSSize(width: 400, height: 127)
        case .preview:
            switch currentVCState {
            case .history:
                transitionOptions = .slideRight
            case .preferences:
                transitionOptions = .slideDown
                viewSize = NSSize(width: 400, height: 348)
            case .preview:
                return
            }
        }

        transition(from: children[currentVCState.rawValue], to: children[targetVCState.rawValue], options: transitionOptions, completionHandler: nil)
        if let size = viewSize {
            let appDelegate = NSApp.delegate as! AppDelegate
            appDelegate.popover.contentSize = size
        }

        currentVCState = targetVCState
    }
}
