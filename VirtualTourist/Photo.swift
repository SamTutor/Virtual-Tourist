//
//  Photo.swift
//  VirtualTourist
//
//  Created by Mac on 5/14/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {
    
    // MARK: Propertes
    
    @NSManaged var photoName: String
    @NSManaged var photoPath: String
    @NSManaged var pin: Pin

    
    // MARK: CoreData
    
    //Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }//END OF INIT
    
    
    // Init photo
    init(pin: Pin, photoName: String, photoPath: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // Initialize stored properties
        self.photoName = photoName
        self.pin = pin
        self.photoPath =  photoPath
        
    }//END OF INIT
    
    
    // MARK: Image

    var photoImage:UIImage? {
        
        // Getting and setting filename as URL's last component
        get {
            return FlickrAPI.Caches.imageCache.imageWithIdentifier(photoName)
        }
        
        set {
            FlickrAPI.Caches.imageCache.storeImage(newValue, withIdentifier: photoPath)
        }
    }//END OF VAR: imageURL

}//END OF CLASS: Photo
