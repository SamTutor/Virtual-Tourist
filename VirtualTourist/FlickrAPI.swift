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
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: GET Photos
    func taskForGETMethod(method:[String:AnyObject], completionHandlerForGET: (success: Bool, result: AnyObject!, errorString: String?) -> Void) -> NSURLSessionDataTask{
        
        //create the request
        let request = NSURLRequest(URL: flickrURLFromParameters(method))
        //DEBUG: print("REQUEST", request)
        
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
            completionHandlerForConvertData(success: false, result: nil, errorString: "Could not parse the data as JSON: '\(data)'")
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
        //DEBUG: print("components", components.URL!)
        return components.URL!
        
    }//END OF FUNC: flickrURLFromParameters

    // Shared Instance
    class func sharedInstance() -> FlickrAPI {
        struct Singleton {
            static var sharedInstance = FlickrAPI ()
        }
    
        return Singleton.sharedInstance
    
    }//END OF FUNC: sharedInstance

    
    //This function returns a task to download photo data given the photo's Flickr URL
    func taskForPhoto (photoURL: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: photoURL)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let _ = error {
                completionHandler(imageData: nil, error: NSError(domain: "taskForPhoto", code: 0, userInfo: [NSLocalizedDescriptionKey : "error with photo download request"]))
            } else {
                completionHandler(imageData: data, error: nil)
            }
            
            
        }
        
        task.resume()
        
        return task
        
    }

    
    
    
    // MARK: - Shared Image Cache
    
    struct Caches {
    
        static let imageCache = ImageCache()
    
    }//End OF STRUCT: Caches
    
}//END OF CLASS: FlickrAPI
