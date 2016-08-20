//
//  Picture.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/27/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Photo: NSManagedObject {
    @NSManaged var pin: Pin
    @NSManaged var id: String?
    @NSManaged  var imageData: NSData
    @NSManaged var imagePath: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: String, imagePath: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.imagePath = imagePath
    }
    
    var image: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier("/\(self.id)")
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: "/\(self.id)")
        }
    }
    

}