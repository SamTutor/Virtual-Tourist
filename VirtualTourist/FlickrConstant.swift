//
//  FlickrConstant.swift
//  VirtualTourist
//
//  Created by Mac on 5/14/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import UIKit

// MARK: Flickr Constants

struct Constants {
    
    // MARK: Basic Constants URL
    struct FlickrBasicURL {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let FlickrPhotosDataURL = APIScheme+"://"+APIHost+APIPath
        
    }//END OF STRUCT: Basic Constants URL
    
    
    // MARK: Search Parameters
    struct FlickrSearchParameters {
        //Box
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        
        static let SearchWidth = BOUNDING_BOX_HALF_WIDTH
        static let SearchHeight = BOUNDING_BOX_HALF_HEIGHT
        
        //Range
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        
        static let LONG_MIN = -180.0
        static let LONG_MAX = 180.0
        
        static let SearchLatRange = (LAT_MIN, LAT_MAX)
        static let SearchLonRange = (LONG_MIN, LONG_MAX)
    
    }//END OF STRUCT: FlickrSearchParameters
    
    
    // MARK: Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let OutputFormat = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"

        static let Extras = "extras"
        static let Text = "text"
        static let GalleryID = "gallery_id"
        static let BoundingBox = "bbox"
        static let PerPage = "per_page"
        static let Page = "page"
        
    }//END OF STRUCT: Parameter Keys
    
    
    // MARK: Parameter Values
    struct FlickrParameterValues {
        
        // Method
        static let SearchMethod = "flickr.photos.search"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        
        // APIKey
        static let APIKey = "fe87322b13a9c07a1a6d924e1570c4af"
        
        // OutputFormat
        static let ResponseFormat = "json"
        
        //NoJSONCallBack
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        
        //Safeearch
        static let UseSafeSearch = "1"

        //Extras
        static let MediumURL = "url_m"

        //PerPage
        static let PicsPerPage = "21"

        //Page
        static let NumOfPages = "2"
        
        //GalleyID
        static let GalleryID = "5704-72157622566655097"
        
    }//END OF STRUCT: Parameter Values
    
    
    // MARK: Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    
    }//END OF STRUCT: Response Keys
    
    
    // MARK: Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    
    }//END OF STRUCT: Response Values
    
}//END OF STRUCT: Constants