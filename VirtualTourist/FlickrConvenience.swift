//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Mac on 5/14/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import UIKit
import MapKit
import Foundation

// MARK: - FlickrAPI (Convenient Resource Methods)

extension FlickrAPI {
    
    
    // MARK: GET Convenience Methods
    
    // Get Flickr Photos
    func getPhotos(pin: Pin, completionHandlerForPhotos: (success: Bool, result: [Photo]?, errorString: String?) -> Void) {
        
        // Method Parameters
        let methodParameters: [String: String!] = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
           //Constants.FlickrParameterKeys.BoundingBox: bboxString(pin),
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.OutputFormat: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = Constants.FlickrParameterValues.NumOfPages
        
        /* 2. Make the request */
        taskForGETMethod(methodParametersWithPageNumber ) { (success, results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForPhotos(success: false, result: nil, errorString: error)
                
            } else {
                completionHandlerForPhotos(success: false, result: nil, errorString: error)
                // if an image exists at the url, set the image and title
//  let imageURL = NSURL(string: result)
//                if let imageData = NSData(contentsOfURL: imageURL!) {
//                    performUIUpdatesOnMain {
//          print (imageDate)
//                        self.photoImageView.image = UIImage(data: imageData)
//                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                    }

            }
        }
        
    }//END OF FUNC: getPhotos
    
    
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
        
        print("\(min_long),\(min_lat),\(max_long),\(max_lat)")
        return "\(min_long),\(min_lat),\(max_long),\(max_lat)"
        
    }//END OF FUNC: bboxString

        
}//END OF EXTENSION: FlickrAPI

