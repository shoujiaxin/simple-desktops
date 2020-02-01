//
//  PreferencesViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet var changePictureButton: NSButton!
    @IBOutlet var intervalPopUpButton: NSPopUpButton!
    @IBOutlet var doneButton: PillButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.attributedTitle = NSMutableAttributedString(string: "Done", attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])
    }

    @IBAction func changePictureButtonClicked(_ sender: NSButton) {
        intervalPopUpButton.isEnabled = (sender.state == NSControl.StateValue.on) ? true : false
    }

    @IBAction func doneButtonClicked(_: Any) {
        let viewController = parent as! PopoverViewController
        viewController.preferencesButtonClicked(self)
    }

    @IBAction func quitButtonClicked(_: Any) {
        NSApp.terminate(self)
    }
}
