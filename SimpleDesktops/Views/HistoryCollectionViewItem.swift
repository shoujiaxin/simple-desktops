//
//  HistoryCollectionViewItem.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/2/2.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import SDWebImage

class HistoryCollectionViewItem: NSCollectionViewItem {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        view.layer?.borderColor = NSColor.controlAccentColor.cgColor
        view.layer?.borderWidth = 0
        view.layer?.cornerRadius = 2
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        view.layer?.borderWidth = 4
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)

        view.layer?.borderWidth = 0
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        guard let index = collectionView?.indexPath(for: self)?.item else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController

        // Cancel loading or downloading
        while popoverViewController.previewViewController.loadingTaskCount > 0 {
            SDWebImageManager.shared.cancelAll()
            SDWebImageDownloader.shared.cancelAllDownloads()

            popoverViewController.previewViewController.stopLoading(self)
        }

        popoverViewController.transition(to: .preview)

        WallpaperManager.shared.selectImage(at: index)
    }

    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)

        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: NSLocalizedString("Set as Wallpaper", comment: ""), action: #selector(setWallpaperMenuItemClicked(sender:)), keyEquivalent: "")
        menu.addItem(withTitle: NSLocalizedString("Show in Finder", comment: ""), action: #selector(showInFinderMenuItemClicked(sender:)), keyEquivalent: "")
        menu.addItem(.separator())
        let deleteMenuItem = menu.addItem(withTitle: NSLocalizedString("Delete", comment: ""), action: #selector(deleteMenuItemClicked(sender:)), keyEquivalent: "")
        for item in menu.items {
            item.target = self
        }

        // Add key equivalent
        deleteMenuItem.keyEquivalentModifierMask = .command
        deleteMenuItem.keyEquivalent = "d"

        // Disable "Reveal in Finder" if the image has NOT been downloaded
        let url = WallpaperManager.wallpaperDirectory.appendingPathComponent(view.toolTip!)
        if !FileManager.default.fileExists(atPath: url.path) {
            menu.item(at: 1)?.isEnabled = false
        }

        menu.popUp(positioning: menu.items[0], at: NSEvent.mouseLocation, in: nil)
    }

    @objc func setWallpaperMenuItemClicked(sender _: Any) {
        guard let index = collectionView?.indexPath(for: self)?.item else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController

        // Return to preview view
        popoverViewController.transition(to: .preview)

        WallpaperManager.shared.selectImage(at: index)
        WallpaperManager.shared.change { error in
            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }
        }
    }

    @objc func showInFinderMenuItemClicked(sender _: Any) {
        let url = URL(fileURLWithPath: view.toolTip!, relativeTo: WallpaperManager.wallpaperDirectory)
        NSWorkspace.shared.activateFileViewerSelecting([url.absoluteURL])
    }

    @objc func deleteMenuItemClicked(sender _: Any) {
        guard let indexPath = collectionView?.indexPath(for: self) else {
            return
        }

        WallpaperManager.shared.delete(byName: view.toolTip!)

        // Trash the image file if downloaded
        let url = WallpaperManager.wallpaperDirectory.appendingPathComponent(view.toolTip!)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.trashItem(at: url, resultingItemURL: nil)
        }

        collectionView?.deleteItems(at: [indexPath])
    }
}
