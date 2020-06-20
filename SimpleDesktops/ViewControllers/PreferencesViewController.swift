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
    @IBOutlet var doneButton: PillButton!
    @IBOutlet var intervalPopUpButton: NSPopUpButton!
    @IBOutlet var versionLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.attributedTitle = NSMutableAttributedString(string: NSLocalizedString("Done", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor])

        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        versionLabel.stringValue = "Version \(versionNumber!) (\(buildNumber!))"
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        updatePreferences()
    }

    @IBAction func changePictureButtonClicked(_ sender: NSButton) {
        switch sender.state {
        case NSControl.StateValue.on:
            Options.shared.changePicture = true
            intervalPopUpButton.isEnabled = true

            WallpaperManager.shared.change(every: Options.shared.changeInterval.seconds)
        case NSControl.StateValue.off:
            Options.shared.changePicture = false
            intervalPopUpButton.isEnabled = false
        default:
            return
        }
    }

    @IBAction func doneButtonClicked(_: Any) {
        let parentViewController = parent as! PopoverViewController
        parentViewController.transition(to: .preview)
    }

    @IBAction func intervalChanged(_ sender: NSPopUpButton) {
        Options.shared.changeInterval = Options.ChangeInterval.from(rawValue: sender.indexOfSelectedItem)

        WallpaperManager.shared.change(every: Options.shared.changeInterval.seconds)
    }

    @IBAction func quitButtonClicked(_: Any) {
        NSApp.terminate(self)
    }

    private func updatePreferences() {
        changePictureButton.state = Options.shared.changePicture ? NSControl.StateValue.on : NSControl.StateValue.off
        intervalPopUpButton.selectItem(at: Int(Options.shared.changeInterval.rawValue))
        intervalPopUpButton.isEnabled = Options.shared.changePicture
    }
}
