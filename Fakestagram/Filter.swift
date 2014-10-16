//
//  Filter.swift
//  Fakestagram
//
//  Created by Casey R White on 10/15/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var favorited: NSNumber

}
