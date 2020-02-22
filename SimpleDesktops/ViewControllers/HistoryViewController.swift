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

    private var wallpaperManager: WallpaperManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColors = [.clear]

        wallpaperManager = (parent as! PopoverViewController).wallpaperManager
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        collectionView.reloadData()
    }

    @IBAction func backToPreviewButtonClicked(_: Any) {
        let parentViewController = parent as! PopoverViewController
        parentViewController.transition(to: .preview)
    }
}

extension HistoryViewController: NSCollectionViewDataSource {
    func collectionView(_: NSCollectionView, numberOfItemsInSection _: Int) -> Int {
        return wallpaperManager.source?.images.count ?? 0
    }

    func collectionView(_: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("HistoryCollectionViewItem"), for: indexPath) as! HistoryCollectionViewItem

        item.imageView?.image = nil
        item.imageView?.toolTip = "Loading..."
        wallpaperManager.source?.images[indexPath.item].previewImage { image, _ in
            DispatchQueue.main.sync {
                item.imageView?.image = image
                item.imageView?.toolTip = self.wallpaperManager.source?.images[indexPath.item].name
            }
        }

        return item
    }
}
