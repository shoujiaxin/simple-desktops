//
//  HistoryViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa

class HistoryViewController: NSViewController {
    @IBOutlet var collectionView: NSCollectionView!

    var wallpaperManager: WallpaperManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColors = [.clear]

        let parentViewController = parent as! PopoverViewController
        wallpaperManager = parentViewController.previewViewController.wallpaperManager
        wallpaperManager?.getHistoryWallpapers()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        let queue = DispatchQueue(label: "UpdateHistoryView")
        queue.async {
            self.wallpaperManager?.getHistoryWallpapers()

            DispatchQueue.main.sync {
                self.collectionView.reloadData()
            }
        }
    }
}

extension HistoryViewController: NSCollectionViewDataSource {
    func collectionView(_: NSCollectionView, numberOfItemsInSection _: Int) -> Int {
        return wallpaperManager!.historyWallpapers.count
    }

    func collectionView(_: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("HistoryCollectionViewItem"), for: indexPath)

        wallpaperManager?.getHistoryPreview(at: indexPath.item, completionHandler: { image, _ in
            DispatchQueue.main.sync {
                item.imageView?.image = image
            }
       })

        return item
    }
}
