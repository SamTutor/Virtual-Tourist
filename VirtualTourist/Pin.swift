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
    @NSManaged var photos: [Photo]
    
    
    let imageCache = ImageCache()
    
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
    
    
    func deleteAllPhotos() {
        
        for photo in photos {
            deletePhoto(photo)
        }
    }


    func deleteSelectedPhotos(selectedPhotos: [Photo]) {
        for photo in selectedPhotos {
            deletePhoto(photo)
        }
        
    }
    
    func deletePhoto(photo: Photo) {
        /* Delete the photo (including image data from the cache and hard drive) */
        imageCache.deleteImage(photo.photoName)
        sharedContext.deleteObject(photo)
        
        CoreDataStackManager.sharedInstance().saveContext()
    }

    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    
    
}//END OF CLASS: Pin
