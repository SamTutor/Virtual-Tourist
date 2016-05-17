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
    
    @NSManaged var photoName: String?
    @NSManaged var photoPath: String?
    @NSManaged var pin: Pin?

    
    
    // MARK: Types
    
    struct PhotoKey {
        static let PhotoName = "name"
        static let PhotoPath = "photopath"
    }
    
    
    
    // MARK: CoreData
    
    //Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }//END OF INIT
    
    
    
    // MARK: Init
    
    // Init from dictionary
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // Dictionary
        photoName = dictionary[PhotoKey.PhotoName] as? String
        photoPath = dictionary[PhotoKey.PhotoName] as? String
        
    }//END OF INIT
    
    // Init photo
    init?(photoName: String, photoPath: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // Initialize stored properties
        self.photoName = photoName
        self.photoPath =  photoPath
        
    }//END OF INIT
    
    
    
    // MARK: Image

    var imageURL: UIImage? {
        
        // Getting and setting filename as URL's last component
        get {
            let url = NSURL(fileURLWithPath: photoPath!)
            let fileName = url.lastPathComponent
            return FlickrAPI.Caches.imageCache.imageWithIdentifier(fileName!)
        }
        
        set {
            let url = NSURL(fileURLWithPath: self.photoPath!)
            let fileName = url.lastPathComponent
            FlickrAPI.Caches.imageCache.storeImage(newValue, withIdentifier: fileName!)
        }
    }//END OF VAR: imageURL

}//END OF CLASS: Photo
