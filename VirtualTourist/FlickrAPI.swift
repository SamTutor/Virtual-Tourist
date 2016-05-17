//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Mac on 5/14/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation

// MARK: FlickrAPI

class FlickrAPI: NSObject {
    
    // MARK: Properties
    
    //create the session
    var session = NSURLSession.sharedSession()
    
    // MARK: GET Photos
    func taskForGETMethod(method: [String : AnyObject], completionHandlerForGET: (success: Bool, result: AnyObject!, errorString: String?) -> Void) -> NSURLSessionDataTask{
        
        //create the request
        let request = NSURLRequest(URL: flickrURLFromParameters(method))
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandlerForGET(success: false, result: nil, errorString: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299
                else {
                completionHandlerForGET(success: false, result: nil, errorString: "Your request returned a status code other than 2xx!:")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandlerForGET(success: false, result: nil, errorString: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }//END OF FUNC: taskForGETMethod

    
    
    // MARK: Helper Functions
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (success: Bool, result: AnyObject!, errorString: String?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            parsedResult = nil
            completionHandlerForConvertData(success: false, result: nil, errorString: "Could not parse the data as JSON: '\(data)'")
            return
        }
        
        /* GUARD: Did Flickr return an error (stat != ok)? */
        guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
            completionHandlerForConvertData(success: false, result: nil, errorString: "Flickr API returned an error. See error code and message in \(parsedResult)")
            return
        }
        
        /* GUARD: Is "photos" key in our result? */
        guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            completionHandlerForConvertData(success: false, result: nil, errorString: "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
            return
        }
        
        /* GUARD: Is "pages" key in the photosDictionary? */
        guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
            completionHandlerForConvertData(success: false, result: nil, errorString: "Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
            return
        }
        
        completionHandlerForConvertData(success: true, result: parsedResult, errorString: nil)

    }//END OF FUNC: convertDataWithCompletionHandler
    
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.FlickrBasicURL.APIScheme
        components.host = Constants.FlickrBasicURL.APIHost
        components.path = Constants.FlickrBasicURL.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print(components.URL!)
        return components.URL!
    }

// Shared Instance
class func sharedInstance() -> FlickrAPI {
    struct Singleton {
        static var sharedInstance = FlickrAPI ()
    }
    return Singleton.sharedInstance
}//END OF FUNC: sharedInstance

    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }//End OF STRUCT: Caches
    
    

}//END OF CLASS: FlickrAPI
