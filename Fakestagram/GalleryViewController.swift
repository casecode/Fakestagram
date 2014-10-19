//
//  GalleryViewController.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var collectionViewOriginalHeight: CGFloat?
    
    var images = [UIImage]()
    var delegate: ImageSelectorDelegate?
    
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
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        
        self.resetCollectionViewOriginalHeight()
        
        // Use 2 touch pan gesture to avoid conflict with collection view scrolling
        let pan = UIPanGestureRecognizer(target: self, action: "collectionViewPanned:")
        pan.minimumNumberOfTouches = 2
        self.collectionView.addGestureRecognizer(pan)
        
        // Pinch Recognizer for collectionView
        let pinch = UIPinchGestureRecognizer(target: self, action: "collectionViewPinched:")
        self.collectionView.addGestureRecognizer(pinch)
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
        self.delegate?.imageSelected(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionViewPanned(pan: UIPanGestureRecognizer) {
        let translation = pan.translationInView(self.view)
        pan.view!.center = CGPoint(x: pan.view!.center.x + translation.x,
            y: pan.view!.center.y + translation.y)
        pan.setTranslation(CGPointZero, inView: self.view)
    }
    
    // MARK - Pinch Recognizer
    func collectionViewPinched(pinch: UIPinchGestureRecognizer) {
        var originalHeight = self.collectionViewOriginalHeight!
        var currentHeight = self.collectionView.frame.height
        
        if ((pinch.velocity < 0 && currentHeight >= originalHeight * 0.75) || (pinch.velocity > 0 && currentHeight <= originalHeight * 2)) {
            self.collectionView.transform = CGAffineTransformScale(self.collectionView.transform, pinch.scale, pinch.scale)
        }
        pinch.scale = 1
    }
    
    
    override func viewDidLayoutSubviews() {
        self.resetCollectionViewOriginalHeight()
    }
    
    func resetCollectionViewOriginalHeight() {
        self.collectionViewOriginalHeight = self.collectionView.layer.bounds.height
    }
    
}
