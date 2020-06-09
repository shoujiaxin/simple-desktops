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
        let wallpaperManager = popoverViewController.wallpaperManager

        // Cancel loading or downloading
        if popoverViewController.previewViewController.isLoading {
            SDWebImageManager.shared.cancelAll()
            SDWebImageDownloader.shared.cancelAllDownloads()

            popoverViewController.previewViewController.isLoading = false
        }

        popoverViewController.transition(to: .preview)

        wallpaperManager.image = wallpaperManager.source.images[index]
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
        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let wallpaperManager = popoverViewController.wallpaperManager
        guard let index = collectionView?.indexPath(for: self)?.item, let imageName = wallpaperManager.source.images[index].name else {
            return
        }
        let url = wallpaperManager.wallpaperDirectory.appendingPathComponent(imageName)
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
        let previewViewController = popoverViewController.previewViewController
        let wallpaperManager = popoverViewController.wallpaperManager
        wallpaperManager.image = wallpaperManager.source.images[index]

        // Return to preview view
        previewViewController.imageView.sd_setImage(with: wallpaperManager.image?.previewUrl, completed: nil)
        popoverViewController.transition(to: .preview)

        previewViewController.progressIndicator.isIndeterminate = true
        previewViewController.isLoading = true

        wallpaperManager.change { error in
            previewViewController.progressIndicator.isIndeterminate = false
            previewViewController.isLoading = false

            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }
        }
    }

    @objc func showInFinderMenuItemClicked(sender _: Any) {
        guard let index = collectionView?.indexPath(for: self)?.item else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let wallpaperManager = popoverViewController.wallpaperManager

        let url = URL(fileURLWithPath: (wallpaperManager.source.images[index].name)!, relativeTo: wallpaperManager.wallpaperDirectory)
        NSWorkspace.shared.activateFileViewerSelecting([url.absoluteURL])
    }

    @objc func deleteMenuItemClicked(sender _: Any) {
        guard let indexPath = collectionView?.indexPath(for: self) else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let wallpaperManager = popoverViewController.wallpaperManager

        if let removedImageName = wallpaperManager.source.removeImage(at: indexPath.item).name {
            // Trash the latest image
            if wallpaperManager.image?.name == removedImageName {
                wallpaperManager.image = wallpaperManager.source.images.first
            }

            // Trash the image file
            let url = wallpaperManager.wallpaperDirectory.appendingPathComponent(removedImageName)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: url.path) {
                try? fileManager.trashItem(at: url, resultingItemURL: nil)
            }
        }

        // MUST update the data source first
        collectionView?.deleteItems(at: [indexPath])
    }
}
