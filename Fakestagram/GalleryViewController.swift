//
//  GalleryViewController.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import UIKit

protocol GalleryDelegate {
    func didSelectImage(image: UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [UIImage]()
    var delegate: GalleryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image1 = UIImage(named: "photo1.jpeg")
        let image2 = UIImage(named: "photo2.jpeg")
        let image3 = UIImage(named: "photo3.jpeg")
        let image4 = UIImage(named: "photo4.jpeg")
        
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.imageView.image = self.images[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let image = self.images[indexPath.row]
        self.delegate?.didSelectImage(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
