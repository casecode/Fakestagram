//
//  FilteredThumbnail.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import UIKit

class FilteredThumbnailConstructor {
    
    var originalImage: UIImage
    var filteredImage: UIImage?
    var filterName: String
    var imageQueue: NSOperationQueue
    var gpuContext: CIContext
    var ciFilter: CIFilter?
    
    init(originalThumbnail : UIImage, filter: Filter, imageQueue: NSOperationQueue, gpuContext : CIContext) {
        self.originalImage = originalThumbnail
        self.filterName = filter.name
        self.imageQueue = imageQueue
        self.gpuContext = gpuContext
    }
    
    func generateFilteredThumbnail(completionHandler : (filteredThumbnail: UIImage) -> Void) {
        
        self.imageQueue.addOperationWithBlock { () -> Void in
            // Setup filter
            let image = CIImage(image: self.originalImage)
            let imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            self.ciFilter = imageFilter
            
            // Generate filtered image
            let result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            let extent = result.extent()
            let cgImage = self.gpuContext.createCGImage(result, fromRect: extent)
            self.filteredImage = UIImage(CGImage: cgImage)
            
            // Resolve callback on main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(filteredThumbnail: self.filteredImage!)
            })
        }
    }
    
}