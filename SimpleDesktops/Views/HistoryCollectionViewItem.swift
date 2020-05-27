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
        if popoverViewController.previewViewController.isUpdating {
            SDWebImageManager.shared.cancelAll()
            SDWebImageDownloader.shared.cancelAllDownloads()

            popoverViewController.previewViewController.isUpdating = false
        }

        popoverViewController.transition(to: .preview)

        wallpaperManager.image = wallpaperManager.source.images[index]
    }

    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)

        let menu = NSMenu()
        menu.addItem(withTitle: NSLocalizedString("Set as Wallpaper", comment: ""), action: #selector(setWallpaperMenuItemClicked(sender:)), keyEquivalent: "")
        menu.addItem(withTitle: NSLocalizedString("Reveal in Finder", comment: ""), action: #selector(revealInFinderMenuItemClicked(sender:)), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: NSLocalizedString("Move to Trash", comment: ""), action: #selector(moveToTrashMenuItemClicked(sender:)), keyEquivalent: "")
        for item in menu.items {
            item.target = self
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

        // Return to preview view
        popoverViewController.transition(to: .preview)

        previewViewController.isUpdating = true
        wallpaperManager.image = wallpaperManager.source.images[index]
        wallpaperManager.change { error in
            previewViewController.isUpdating = false

            if let error = error {
                Utils.showCriticalAlert(withInformation: error.localizedDescription)
                return
            }
        }
    }

    @objc func revealInFinderMenuItemClicked(sender _: Any) {
        guard let index = collectionView?.indexPath(for: self)?.item else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let wallpaperManager = popoverViewController.wallpaperManager

        let url = URL(fileURLWithPath: (wallpaperManager.source.images[index].name)!, relativeTo: wallpaperManager.wallpaperDirectory)
        NSWorkspace.shared.activateFileViewerSelecting([url.absoluteURL])
    }

    @objc func moveToTrashMenuItemClicked(sender _: Any) {
        guard let indexPath = collectionView?.indexPath(for: self) else {
            return
        }

        let appDelegate = NSApp.delegate as! AppDelegate
        let popoverViewController = appDelegate.popover.contentViewController as! PopoverViewController
        let wallpaperManager = popoverViewController.wallpaperManager

        collectionView?.deleteItems(at: [indexPath])

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
    }
}
