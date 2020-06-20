//
//  HistoryViewController.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/31.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Cocoa
import SDWebImage

class HistoryViewController: NSViewController {
    @IBOutlet var collectionView: NSCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColors = [.clear]
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

// MARK: NSCollectionViewDataSource

extension HistoryViewController: NSCollectionViewDataSource {
    func collectionView(_: NSCollectionView, numberOfItemsInSection _: Int) -> Int {
        return WallpaperManager.shared.images.count
    }

    func collectionView(_: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("HistoryCollectionViewItem"), for: indexPath) as! HistoryCollectionViewItem

        item.imageView?.image = nil
        item.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
        item.imageView?.sd_imageIndicator?.startAnimatingIndicator()
        item.imageView?.toolTip = "Loading..."

        item.imageView?.sd_setImage(with: WallpaperManager.shared.images[indexPath.item].previewUrl, placeholderImage: nil, completed: { _, _, _, _ in
            item.imageView?.toolTip = WallpaperManager.shared.images[indexPath.item].name
        })

        return item
    }
}
