//
//  PhotosViewController.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import UIKit
import Photos

protocol PhotosDelegate {
    func photoSelected(photo: UIImage)
}

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var imageManager: PHCachingImageManager!
    var assets: PHFetchResult!
    var assetCollection: PHAssetCollection!
    var assetCellSize: CGSize!
    var delegate: PhotosDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set image manager
        self.imageManager = PHCachingImageManager()
        
        // Fetch assets
        self.assets = PHAsset.fetchAssetsWithOptions(nil)
        
        // Determine device scale and adjust asset cell size accordingly
        let scale = UIScreen.mainScreen().scale
        let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        let cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    }
    
    // MARK - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as PhotoCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = self.assets[indexPath.row] as PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            if cell.tag == currentTag {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.assets[indexPath.row] as PHAsset
        self.imageManager.requestImageDataForAsset(asset, options: nil) { (imageData, dataUTI, orientation, info) -> Void in
            let photo = UIImage(data: imageData)
            self.delegate?.photoSelected(photo!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
