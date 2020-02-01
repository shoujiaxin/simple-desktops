//
//  UpdateButton.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/28.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class UpdateButton: NSButton {
    private var rectColor = NSColor.windowBackgroundColor.cgColor

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        rectColor = NSColor.windowBackgroundColor.cgColor

        layer?.borderWidth = 0
        layer?.cornerRadius = 6
        layer?.backgroundColor = CGColor(red: rectColor.components![0], green: rectColor.components![1], blue: rectColor.components![2], alpha: 0.2)

        let rect = NSRect(x: bounds.origin.x - bounds.width, y: bounds.origin.y - bounds.height, width: bounds.width * 3, height: bounds.height * 3)
        let trackingArea = NSTrackingArea(rect: rect, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    override func layout() {
        super.layout()

        imageScaling = NSImageScaling.scaleNone
        if let image = self.image {
            image.size = NSSize(width: 32, height: 32)
            image.tint(withColor: NSColor.textColor)
        }
    }

    override func mouseEntered(with _: NSEvent) {
        layer?.backgroundColor = CGColor(red: rectColor.components![0], green: rectColor.components![1], blue: rectColor.components![2], alpha: 0.8)
    }

    override func mouseExited(with _: NSEvent) {
        layer?.backgroundColor = CGColor(red: rectColor.components![0], green: rectColor.components![1], blue: rectColor.components![2], alpha: 0.2)
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
