//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Mac on 5/14/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

// MARK: - FlickrAPI (Convenient Resource Methods)

extension FlickrAPI {
    
    
    // MARK: GET Convenience Methods
    
    // Get Flickr Photos
    func getPhotos(pin: Pin, completionHandlerForPhotos: (success: Bool, result: AnyObject!,errorString: String?) -> Void) {
        
        // Method Parameters
        let methodParameters: [String: String!] = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(pin),
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.OutputFormat: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PicsPerPage,
            Constants.FlickrParameterKeys.Page: Constants.FlickrParameterValues.NumOfPages
        ]
        
        // Add numPages
        var withPageDictionary = methodParameters
        withPageDictionary["page"] = String(pin.numPages)
        
        /* 2. Make the request */
        taskForGETMethod(withPageDictionary) { (success, results, error) in
            if let error = error {
                print ("JSON Error")
            } else {
                // GUARD: Did Flickr return an stat error of NOT OK
                guard let stat = results["stat"] as? String
                    where stat == "ok"
                    else {
                        print("Flickr API returned an error. See error code and message in \(results)")
                        completionHandlerForPhotos(success: false, result: nil, errorString: "There was an error with the Flickr service.")
                        return
                    }
                
                // GUARD: Is the "PHOTOS" keyword in our Parsed result?
                guard let photosDictionary = results["photos"] as? NSDictionary
                    else {
                        print("Cannot find keyword 'photos' in \(results)")
                        completionHandlerForPhotos(success: false, result: nil, errorString: "There was an error reading the photo data.")
                        return
                    }

                
                // GUARD: Is the "TOTAL" key in photosDictionary? */
                guard let totalPhotos = (photosDictionary["total"] as? NSString)?.integerValue
                    else {
                        print("Cannot find key 'total' in \(photosDictionary)")
                        completionHandlerForPhotos(success: false, result: nil, errorString: "There was an error reading the photo data.")
                        return
                    }
                
                // GUARD: Is the "PHOTO" key in photosDictionary? */
                guard let photoArray = photosDictionary["photo"] as? [[String: AnyObject]]
                    else {
                        print("Cannot find key 'photo' in \(photosDictionary)")
                        completionHandlerForPhotos(success: false, result: nil, errorString: "There was an error reading the photo data.")
                        return
                    }
                
                if (photoArray.count == 0 && totalPhotos > 0){
                    completionHandlerForPhotos(success: false, result: nil, errorString: "There are no MORE photos for this location.")
                }
                else if (photoArray.count == 0 && totalPhotos == 0) {
                    completionHandlerForPhotos(success: false, result: nil, errorString: "There are NO photos for this location.")
                }
                else {
                    // Check Each Photo
                    for photo in photoArray {
                        // GUARD: Does our photo have a "URL_M"
                        guard let photoPath = photo["url_m"] as? String
                            else {
                                print("Cannot find key 'url_m' in \(photo)")
                                completionHandlerForPhotos(success: false, result: nil, errorString: "There was an error reading the photo data.")
                                return
                            }
                        
                        // GUARD: Does our photo have a "ID"
                        guard let photoName = photo["id"] as? String
                            else {
                                print("Cannot find key 'id' in \(photo)")
                                completionHandlerForPhotos(success: false, result: nil, errorString: "There was an error reading the photo data.")
                                return
                            }
                        
                        performOnMain {
                            let photoObject = Photo(pin: pin, photoName: photoName, photoPath:photoPath, context:  self.sharedContext)
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                    }
                    
                    performOnMain {
                        pin.numPages = pin.numPages + 1
                    }
                    
                    completionHandlerForPhotos(success: true, result: nil, errorString: nil)
                }
                
            }
        
        }

    }//END OF FUNC: getPhotos
    
    func displayPhoto(photo: Photo, completionHandlerDisplay: (success: Bool, errorString: String?) -> Void) {
        
        // citation: http://stackoverflow.com/questions/28868894/swift-url-reponse-is-nil
        let session = NSURLSession.sharedSession()
        let imageURL = NSURL(string: photo.photoPath)
        
        let sessionTask = session.dataTaskWithURL(imageURL!) { data, response, error in
            
            // GUARD: Was data returned?
            guard let data = data
                else {
                completionHandlerDisplay(success: false, errorString: error?.localizedDescription)
                return
                }
            
            performOnMain {
                photo.photoImage = UIImage(data: data)
            }
            //DEBUG: print (photo.photoImage)
            completionHandlerDisplay(success: true, errorString: nil)
        }
        
        sessionTask.resume()
        
    }//END OF FUNC: displayPhoto
    
                
    
    // MARK: Helper Functions

    /* Set the box boundaries of the search for the pin location */
    func bboxString(pin: MKAnnotation) -> String {
        // ensure bbox is bounded by minimum and maximums
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
            /* |-------------------| */
            /* |    MAX LATITUDE   | */
            /* |                   | */
            /* |      LATITUDE     | */
            /* |                   | */
            /* |    MIN LATITUDE   | */
            /* |-------------------| */
        
            let max_lat = min(latitude + Constants.FlickrSearchParameters.SearchHeight, Constants.FlickrSearchParameters.SearchLatRange.1)
            let min_lat = max(latitude - Constants.FlickrSearchParameters.SearchHeight, Constants.FlickrSearchParameters.SearchLatRange.0)
        
            /* |---------------------| */
            /* |    MAX LONGITUDE    | */
            /* |                     | */
            /* |      LONGITUDE      | */
            /* |                     | */
            /* |    MIN LONGITUDE    | */
            /* |---------------------| */
        
            let max_long = min(longitude + Constants.FlickrSearchParameters.SearchWidth, Constants.FlickrSearchParameters.SearchLonRange.1)
            let min_long = max(longitude - Constants.FlickrSearchParameters.SearchWidth, Constants.FlickrSearchParameters.SearchLonRange.0)
        
        //print("BoundingBox", "\(min_long),\(min_lat),\(max_long),\(max_lat)")
        return "\(min_long),\(min_lat),\(max_long),\(max_lat)"
        
    }//END OF FUNC: bboxString

    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
}//END OF EXTENSION: FlickrAPI

