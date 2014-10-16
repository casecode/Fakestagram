//
//  CoreDataSeeder.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import Foundation
import CoreData

class CoreDataSeeder {
    let managedObjectContext: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedData() {
        
        let filters = [
            "CISepiaTone"           : true,
            "CIGaussianBlur"        : true,
            "CIGammaAdjust"         : false,
            "CIExposureAdjust"      : false,
            "CIPixellate"           : true,
            "CIPhotoEffectChrome"   : false,
            "CIPhotoEffectInstant"  : false,
            "CIPhotoEffectMono"     : false,
            "CIPhotoEffectNoir"     : true,
            "CIPhotoEffectTonal"    : false
        ]
        
        for (filterName, favorited) in filters {
            let filter = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
            filter.name = filterName
            filter.favorited = favorited
        }
        
        var error: NSError?
        self.managedObjectContext.save(&error)
        
        if error != nil {
            println(error?.localizedDescription)
        }
    }
}