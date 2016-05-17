//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mac on 5/13/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapInstructions: UILabel!
    @IBOutlet weak var mapNavigationBar: UINavigationItem!
    
    
    
    // MARK: Variables
    
    let deletePinsMessage = "TAP ON PIN(S) TO DELETE"
    let addPinsMessage = "PRESS ON MAP TO ADD PINS"
    var mapMode = "Add"
    var latDelta = 0

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Loads the Map Region
        loadMapRegion()
        
        //Load the Map Pins
        if let pins = loadPins() {
            addloadedPins(pins)
        }
        
        //Default the Instrutions to Add Pins on the map
        mapInstructions.text = addPinsMessage
        mapInstructions.backgroundColor = UIColor.darkGrayColor()
        

        
        //Long Press to Add Pins
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(VTMapViewController.addPins(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)
        
        //Handles the mapView through delegate callbacks
        mapView.delegate = self
    
    
    }//END OF FUNC: viewDidLoad
    

    
    //MARK: Core Data
    
    /**
     * This is the convenience method for fetching all persistent pins
     *
     * The method creates a "Fetch Request" and then executes the request on
     * the shared context.
     */
    
    func loadPins() -> [Pin]? {
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var savedPins = [Pin]()
        
        // Execute the Fetch Request
        do {
            savedPins = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print ("Problem with retrieving Pins from Core Data!")
        }
        
        return savedPins
        
    }//END OF FUNC: fetchAllPins()

    
    func addloadedPins(pins: [Pin]) -> Void {
        
        for pin in pins {
            
            let pinToMap = MKPointAnnotation()
            pinToMap.coordinate = pin.coordinate
            
            //let pinToMapView = MKPinAnnotationView(annotation: pinToMap, reuseIdentifier: nil)
            //pinToMapView.animatedDrop = true
            //pinToMapView.draggable = true
            
            performOnMain {self.mapView.addAnnotation(pinToMap)}
        }
    }//END OF FUNC: addloadedPins
    
    
    
    // MARK: MAP FILE
    
    var filePath : String {
        //convenience property to return the file path for where the map location is stored
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegion").path!
    
    }//END OF VAR: filePath
    
    
    // MARK: MAP Region
   
    func loadMapRegion() {
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            if (NSUserDefaults.standardUserDefaults().doubleForKey("latitudeDelta") != 0) {
                let lat = regionDictionary["latitude"] as! CLLocationDegrees
                let long = regionDictionary["longitude"] as! CLLocationDegrees
                
                let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let latDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
                let longDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
                
                let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                
                let savedRegion = MKCoordinateRegion(center: center, span: span)
                
                self.mapView.setRegion(savedRegion, animated: true)
            }
        }
        
    }//End OF FUNC: mapRegion
    
    
    
    func saveMapRegion() {
        
        // dictionary of the mapView Region
        let mapRegionDictionary = [
            "latitude": mapView.region.center.latitude,
            "longitude": mapView.region.center.longitude,
            "latDelta":mapView.region.span.latitudeDelta,
            "longDelta":mapView.region.span.longitudeDelta
        ]
        
        // save the dictionary to default
        NSKeyedArchiver.archiveRootObject(mapRegionDictionary, toFile: filePath)
        
    }//END OF FUNC: saveMapRegion
    
    
    
    
    
    // MARK: Mapview
    
    //Return the matching Pin managed object for the annotation
    func pinForAnnotation(annotation: MKAnnotation) -> Pin? {
        
        var returnPin: Pin?
        let pins = loadPins()       //Load the pins from the fetched results controller
        for pinA in pins! {
            let pinLat = pinA.valueForKey("pinLatitude") as! Double
            let pinLong = pinA.valueForKey("pinLongitude") as! Double
            if (pinLat == annotation.coordinate.latitude && pinLong == annotation.coordinate.longitude )
            {
                returnPin = pinA
                break
            }
        }
        
        return returnPin
    }//END OF FUNC: pinForAnnotation

    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }//END OF FUNC: mapView regionDidChangeAnimated
    
    
    //Tells the delegate that one of its annotation views was selected.
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let selAnn = view.annotation
        if let selectedPin = pinForAnnotation(selAnn!) {
            if (self.mapMode == "Add") {
                //Go to VTDetailsViewController
                let controller = storyboard!.instantiateViewControllerWithIdentifier("VTDetailsViewController") as! VTDetailsViewController
                controller.pinPhotos = selectedPin
            
            
                // allows consecutive annotation selections
                mapView.deselectAnnotation(selectedPin, animated: true)
            
                self.navigationController?.pushViewController(controller, animated: true)
            
            } else {
                print("Delete")
                mapView.removeAnnotation(view.annotation!)
            
                /* Save the context */
                CoreDataStackManager.sharedInstance().saveContext()

            }
        }
    }//END OF FUNC: mapView didSelectAnnotationView
    
    
    
    // MARK: Actions
    
    
    func addPins(sender: UIGestureRecognizer) {
        if (self.mapMode == "Add") {
            
            if sender.state != UIGestureRecognizerState.Began {
                return
            }
            
            let pinPoint:CGPoint = sender.locationInView(mapView)
            print (pinPoint)
            
            let pinCoord : CLLocationCoordinate2D = mapView.convertPoint(pinPoint, toCoordinateFromView: mapView)
            print (pinCoord)
            
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = pinCoord
            
            performOnMain {
                self.mapView.addAnnotation(dropPin)
            }
            
            let pinToPhoto = Pin(lat: pinCoord.latitude, long: pinCoord.longitude, context: self.sharedContext)

            performOnMain {
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
        }
        
    }//END OF FUNC: addPins

    
    @IBAction func delPins(sender: UIBarButtonItem) {
        if (mapNavigationBar.rightBarButtonItem?.image == UIImage(named: "Delete")) {
            self.mapMode = "Delete"
            mapInstructions.text = deletePinsMessage
            mapInstructions.backgroundColor = UIColor.orangeColor()
            mapNavigationBar.rightBarButtonItem?.image = UIImage(named:"Done")
        } else {
            self.mapMode = "Add"
            mapInstructions.text = addPinsMessage
            mapInstructions.backgroundColor = UIColor.darkGrayColor()
            mapNavigationBar.rightBarButtonItem?.image = UIImage(named:"Delete")
        }
        
    }//END OF FUNC: delPins
    

    // MARK: NSCoding
    
    
    
    

    
}// END OF CLASS: VTMapViewController

