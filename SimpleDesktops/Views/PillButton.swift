//
//  PillButton.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class PillButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        layer?.backgroundColor = CGColor(gray: 0.6, alpha: 0.2)
        layer?.borderColor = CGColor(gray: 0.5, alpha: 0.4)
        layer?.borderWidth = 1
        layer?.cornerRadius = frame.width < frame.height ? frame.width / 2 : frame.height / 2
    }
}
