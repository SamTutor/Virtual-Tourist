
//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mac on 5/13/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import UIKit
import MapKit

class VTMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapInstructions: UILabel!
    @IBOutlet weak var mapNavigationBar: UINavigationItem!
    
    
    // MARK: Variables
    
    let deletePinsMessage = "TAP ON PIN(S) TO DELETE"
    let addPinsMessage = "PRESS ON MAP TO ADD PINS"
    var mapMode = "Add"

    
    
    // MARK: View Loading

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Long Press to Add Pins
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(VTMapViewController.addPins(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)
        
        
        //Default the Instrutions to Add Pins on the map
        mapInstructions.text = addPinsMessage
        mapInstructions.backgroundColor = UIColor.darkGrayColor()
        
        //Handles the mapView through delegate callbacks
        self.mapView.delegate = self
        
  
    }//END OF FUNC: viewDidLoad

    
    
    // MARK: Actions
    
    
    func addPins(sender: UILongPressGestureRecognizer) {
        print("longpressed")
        let pinPoint:CGPoint = sender.locationInView(mapView)
        //print("pinPoint", pinPoint)
        let pinCoord:CLLocationCoordinate2D = mapView.convertPoint(pinPoint, toCoordinateFromView:mapView)
        //print("pinCoord", pinCoord)
        let newPinAnotation = MKPointAnnotation()
        newPinAnotation.coordinate = pinCoord
        newPinAnotation.title = "New Location"
        newPinAnotation.subtitle = "New Subtitle"
        mapView.addAnnotation(newPinAnotation)
        
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
    


    
}// END OF CLASS: VTMapViewController

