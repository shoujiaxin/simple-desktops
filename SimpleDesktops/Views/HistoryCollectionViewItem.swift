//
//  HistoryCollectionViewItem.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/2/2.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class HistoryCollectionViewItem: NSCollectionViewItem {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        view.layer?.borderColor = NSColor.controlAccentColor.cgColor
        view.layer?.borderWidth = 0

        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        view.layer?.borderWidth = 4
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)

        view.layer?.borderWidth = 0
    }

    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)

        let menu = NSMenu()
        menu.addItem(withTitle: "Set as wallpaper", action: #selector(setWallpaperMenuItemClicked(sender:)), keyEquivalent: "")
        menu.item(at: 0)?.target = self
        menu.addItem(withTitle: "Delete", action: #selector(deleteHistoryMenuItemClicked(sender:)), keyEquivalent: "")
        menu.item(at: 1)?.target = self

        menu.popUp(positioning: menu.items[0], at: NSEvent.mouseLocation, in: nil)
    }

    @objc func setWallpaperMenuItemClicked(sender _: Any) {
        guard let index = collectionView?.indexPath(for: self)?.item else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let previewViewController = popoverViewController.previewViewController
        let wallpaperManager = previewViewController.wallpaperManager

        // Return to preview view
        popoverViewController.historyButtonClicked(self)

        previewViewController.isUpdating = true
        wallpaperManager.selectFromHistory(at: index)
        wallpaperManager.changeWallpaper { error in
            DispatchQueue.main.sync {
                previewViewController.isUpdating = false

                if let error = error {
                    Utils.showCriticalAlert(withInformation: error.localizedDescription)
                    return
                }
            }
        }
    }

    @objc func deleteHistoryMenuItemClicked(sender _: Any) {
        guard let indexPath = collectionView?.indexPath(for: self) else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let previewViewController = popoverViewController.previewViewController
        let wallpaperManager = previewViewController.wallpaperManager

        wallpaperManager.removeFromHistory(at: indexPath.item)
        collectionView?.deleteItems(at: [indexPath])
    }
}
