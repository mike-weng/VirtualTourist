//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/27/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var currentPage: NSNumber
    @NSManaged var photos: [Photo]
    
    var coordinate: CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2D(latitude: Double(self.latitude), longitude: Double(self.longitude))
        return coordinate
    }
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.latitude = annotation.coordinate.latitude
        self.longitude = annotation.coordinate.longitude
        self.currentPage = 1
    }
}
