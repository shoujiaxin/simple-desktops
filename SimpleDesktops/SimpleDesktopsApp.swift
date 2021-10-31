//
//  SimpleDesktopsApp.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SwiftUI
import UserNotifications

// MARK: -

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

// MARK: -

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_: Notification) {
        let viewContext = PersistenceController.shared.container.viewContext

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "photo.on.rectangle", accessibilityDescription: nil)
        statusItem.button?.action = #selector(togglePopover(_:))

        popover = NSPopover()
        popover.behavior = NSPopover.Behavior.transient
        popover.contentViewController = NSHostingController(rootView:
            PopoverView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(PictureService(context: viewContext))
        )

        // Start the timer
        WallpaperManager.shared.autoChangeInterval = Options().changeInterval

        UNUserNotificationCenter.current().delegate = self
    }

    func application(_: NSApplication, open _: [URL]) {
        togglePopover(self)
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: NSRectEdge.minY)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display user notification even while the app is in foreground
        completionHandler([.banner])
    }
}
