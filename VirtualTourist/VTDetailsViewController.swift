//
//  VTDetailsViewController.swift
//  VirtualTourist
//
//  Created by Mac on 5/13/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData


class VTDetailsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var pinMapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    // MARK: Properties
    var selpin: Pin!
    
    var pinLatitude: Double?
    var pinLongitude: Double?
    
     var selectedPhotos = [Photo]()
    
    
    // MARK: viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }//END OF FUNC: viewDidLoad
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        pinMap()
        
        // If No Photos then
        if selpin.photos!.isEmpty {
            newCollectionOfPhotos()
        }
    }

    
    func newCollectionOfPhotos() {
        
        FlickrAPI.sharedInstance().getPhotos(selpin) { (success, results, errorString) in
            
            /* If for some reason the photo locations cannot be downloaded, state why in error message */
            if success == false {
                performOnMain {
                 //   self.errorMessage.text = errorString
                //    self.errorMessage.hidden = false
                }
            }
        }
    }

    
    
    //FUNC: pinManager(): Shows Pin on the Map
    func pinMap() {
        //get the most recent coordinate
        
        
        //get lat and long
        let myLat = selpin.latitude as Double
        let myLong = selpin.longitude as Double
        
        let myCoord2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLong)
        
        //set span
        let myLatDelta = 0.5
        let myLongDelta = 0.5
        let mySpan = MKCoordinateSpan(latitudeDelta: myLatDelta, longitudeDelta: myLongDelta)
        
        //center map at this region
        let myRegion = MKCoordinateRegion(center:myCoord2D, span: mySpan)
        pinMapView.setRegion(myRegion, animated:true)
        
        //add annotation
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = myCoord2D
        pinAnnotation.title = "LAT: "+String(format: "%2.3f",myLat)+", LONG: "+String(format: "%2.3f",myLong)
        
        pinMapView.addAnnotation(pinAnnotation)
        
    }

    
    
}//END OF FUNC: VTDetailsViewController