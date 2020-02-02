//
//  HistoryImageView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/2/2.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class HistoryImageView: NSImageView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        layer?.borderColor = NSColor.controlAccentColor.cgColor
        layer?.borderWidth = 0

        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        layer?.borderWidth = 3
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)

        layer?.borderWidth = 0
    }
}
