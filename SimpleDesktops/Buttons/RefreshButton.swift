//
//  RefreshButton.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/28.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class RefreshButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        appearance = NSAppearance(named: .aqua)

        layer?.borderWidth = 0
        layer?.cornerRadius = 6
        layer?.backgroundColor = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.1)

        let rect = NSRect(x: bounds.origin.x - bounds.width, y: bounds.origin.y - bounds.height, width: bounds.width * 3, height: bounds.height * 3)
        let trackingArea = NSTrackingArea(rect: rect, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    override func layout() {
        super.layout()

        imageScaling = NSImageScaling.scaleNone

        if let image = self.image {
            image.size = NSSize(width: 32, height: 32)
            image.tint(withColor: NSColor.white)
        }
    }

    override func mouseEntered(with _: NSEvent) {
        layer?.backgroundColor = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
    }

    override func mouseExited(with _: NSEvent) {
        layer?.backgroundColor = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.1)
    }
}

extension NSImage {
    func tint(withColor color: NSColor) {
        lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: size)
        imageRect.fill(using: NSCompositingOperation.sourceAtop)

        unlockFocus()
    }
}
