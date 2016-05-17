//
//  Pin.swift
//  VirtualTourist
//
//  Created by Mac on 5/13/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class Pin: NSManagedObject, MKAnnotation {
    
    // MARK: Propertes
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var numPages: Int
    @NSManaged var photos: [Photo]?
    
    // MARK: Core Data
    // MARK: Init
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        //Standard Core Data init method
        super.init(entity: entity, insertIntoManagedObjectContext: context)

    }//END OF INIT
    

    init(lat: Double, long: Double, context: NSManagedObjectContext) {

        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Initialize stored properties
        latitude = NSNumber(double:lat)
        longitude = NSNumber(double:long)
        
    }//END OF INIT
    
    var coordinate : CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }

    
}//END OF CLASS: Pin
