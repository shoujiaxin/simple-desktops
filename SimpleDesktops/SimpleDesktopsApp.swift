//
//  SimpleDesktopsApp.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SwiftUI

@main
struct SimpleDesktopsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Group {
                // No window
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "photo.on.rectangle", accessibilityDescription: nil)
        statusItem.button?.action = #selector(togglePopover(_:))

        popover = NSPopover()
        popover.behavior = NSPopover.Behavior.transient
        popover.contentViewController = NSHostingController(rootView: PopoverView())
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: NSRectEdge.minY)
        }
    }
}
