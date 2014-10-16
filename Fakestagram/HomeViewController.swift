//
//  ViewController.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
import OpenGLES

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate, PhotosDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var originalThumbnail: UIImage?
    var filters: [Filter]?
    var filteredThumbnailConstructors = [FilteredThumbnailConstructor]()
    var gpuContext: CIContext?
    let imageQueue = NSOperationQueue()
    var currentImageIsFiltered = false

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Constraints
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        self.fetchFilters()
        self.setGPUContext()
        
        self.collectionView.dataSource = self
    }
    
    // Fetch filters from CoreData
    func fetchFilters() {
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        var error: NSError?
        if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter] {
            if filters.isEmpty {
                let coreDataSeeder = CoreDataSeeder(context: self.managedObjectContext!)
                coreDataSeeder.seedData()
                self.filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter]
            } else {
                self.filters = filters
            }
        }
    }
    
    // Set gpu context
    func setGPUContext() {
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    }
    
    // MARK - Reset thumbnails
    func resetThumbnails() {
        
        // Create thumbnail of currently selected image
        var size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //now we need to setup our thumbnail containers
        var constructors = [FilteredThumbnailConstructor]()
        for filter in self.filters! {
            let constructor = FilteredThumbnailConstructor(originalThumbnail: self.originalThumbnail!, filter: filter, imageQueue: self.imageQueue, gpuContext: self.gpuContext!)
            constructors.append(constructor)
        }
        self.filteredThumbnailConstructors = constructors
        self.collectionView.reloadData()
    }
    
    // When choosePhotoButton pressed, add action sheet with options for choosing photo
    @IBAction func choosePhotoButtonPressed(sender: AnyObject) {
        // Set up action sheet
        let alertController = UIAlertController(title: nil, message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Photos Action
        let photosAction = UIAlertAction(title: "My Photos", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_PHOTOS", sender: self)
        }
        alertController.addAction(photosAction)
        
        // Gallery Action
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        alertController.addAction(galleryAction)
        
        // Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            } else {
                imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            }
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        
        // Filter action
        // Only allow filtering if there is an image and if that image is not already filtered
        if self.imageView.image != nil && self.currentImageIsFiltered == false {
            let filterAction = UIAlertAction(title: "Filter Current Image", style: UIAlertActionStyle.Default) { (action) -> Void in
                self.enterFilterMode()
            }
            alertController.addAction(filterAction)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK - Prepare for Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let galleryVC = segue.destinationViewController as GalleryViewController
            galleryVC.delegate = self
        } else if segue.identifier == "SHOW_PHOTOS" {
            let photosVC = segue.destinationViewController as PhotosViewController
            photosVC.delegate = self
        }
    }
    
    // MARK - Filtering
    func enterFilterMode() {
        self.imageViewLeadingConstraint.constant *= 4
        self.imageViewTrailingConstraint.constant *= 4
        self.imageViewBottomConstraint.constant += 150
        self.collectionViewBottomConstraint.constant = 75
        
        self.choosePhotoButton.hidden = true
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        var barButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func exitFilterMode() {
        self.imageViewLeadingConstraint.constant /= 4
        self.imageViewTrailingConstraint.constant /= 4
        self.imageViewBottomConstraint.constant -= 150
        self.collectionViewBottomConstraint.constant = -150
        
        self.choosePhotoButton.hidden = false
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.currentImageIsFiltered = false
        self.dismissViewControllerAnimated(true, completion: nil)
        self.resetThumbnails()
    }
    
    // MARK - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredThumbnailConstructors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("FILTERED_THUMBNAIL_CELL", forIndexPath: indexPath) as FilteredThumbnailCell
        let currentTag = cell.tag + 1
        cell.tag = currentTag

        let filteredThumbConstructor = self.filteredThumbnailConstructors[indexPath.row]
        if let filteredThumbnail = filteredThumbConstructor.filteredImage {
            cell.imageView.image = filteredThumbnail
        } else {
            filteredThumbConstructor.generateFilteredThumbnail({ (filteredThumbnail) -> Void in
                if cell.tag == currentTag {
                    cell.imageView.image = filteredThumbnail
                }
            })
        }
        
        return cell
    }
    
    // MARK - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filteredThumbConstructor = self.filteredThumbnailConstructors[indexPath.row]
        let filterName = filteredThumbConstructor.filterName
        let currentImage = self.imageView.image!
        
        self.imageQueue.addOperationWithBlock { () -> Void in
            // Setup filter
            let image = CIImage(image: currentImage)
            let imageFilter = CIFilter(name: filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            // Generate filtered image
            let result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            let extent = result.extent()
            let cgImage = self.gpuContext!.createCGImage(result, fromRect: extent)
            let filteredImage = UIImage(CGImage: cgImage)
            
            // Resolve callback on main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.imageView.image = filteredImage
                self.currentImageIsFiltered = true
                self.exitFilterMode()
                self.resetThumbnails()
                self.collectionView.reloadData()
            })
        }
    }
    
    // MARK - GalleryDelegate
    func didSelectImage(image: UIImage) {
        self.imageView.image = image
        self.currentImageIsFiltered = false
        self.resetThumbnails()
    }
    
    // MARK - PhotosDelegate
    func photoSelected(photo: UIImage) {
        self.imageView.image = photo
        self.currentImageIsFiltered = false
        self.resetThumbnails()
    }
    
}

