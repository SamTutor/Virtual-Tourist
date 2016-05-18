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


class VTDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    
    // MARK: Properties
    
    @IBOutlet weak var collMessage: UIBarButtonItem!
    @IBOutlet weak var pinMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    
    
    // MARK: Variables
    
    var selpin: Pin!
    var selectedPhotos = [Photo]()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    
    // MARK: View Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Load the Photos
        
        do {
            try loadPhotos.performFetch()
        } catch {
            print("Error fetching Pictures for pin: \(error)")
            abort()
        }
        
        //self.collectionView.delegate = self
        //self.collectionView.dataSource = self
        loadPhotos.delegate = self
        
    }//END OF FUNC: viewDidLoad
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        pinMap()
        
        // If No Photos Saved then
        if selpin.photos.isEmpty {
            newCollectionPhotos()
        }


        
    }//END OF FUNC: viewWillAppear

    
    
    // MARK: API
    
    func newCollectionPhotos() {
        
        FlickrAPI.sharedInstance().getPhotos(selpin) { (success, results, errorString) in
            
            if success == false {
                performOnMain {
                    self.collMessage.title = "Cannot FIND Photos"
                }
            }
        }
        
    }//END OF FUNC: newCollectionPhotos

    
    
    // MARK: MAP
    
    func pinMap() {
        
        // Get lat and long
        let myLat = selpin.latitude as Double
        let myLong = selpin.longitude as Double

        // Get Coordinates
        let myCoord2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLong)
        
        // Set lat and long delta
        let myLatDelta = 0.2
        let myLongDelta = 0.2
        
        // Set Span
        let mySpan = MKCoordinateSpanMake(myLatDelta, myLongDelta)
        
        // Center map at this region
        let myRegion = MKCoordinateRegionMake(myCoord2D, mySpan)
        pinMapView.setRegion(myRegion, animated:false)
        
        // Add annotation
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = myCoord2D
        pinAnnotation.title = "LAT: "+String(format: "%2.3f",myLat)+", LONG: "+String(format: "%2.3f",myLong)
        performOnMain {
            self.pinMapView.addAnnotation(pinAnnotation)
        }
    }//END OF FUNC: pinMap

    
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    // MARK: Collection View
    
    
    
    // MARK: - Load Photos
    
    lazy var loadPhotos: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
            fetchRequest.sortDescriptors = []
            fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selpin);
        
        let loadPhotos = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return loadPhotos
        
    }()//END OF VAR: load Photos

    
    
    
    
    // MARK: Collection Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with 5 points space in between.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .Vertical
        
        let width = floor((self.collectionView.frame.size.width-10)/3)
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView.collectionViewLayout = layout
   
    }//END OF FUNC: viewDidLayoutSubviews
    
    
    
    // MARK: Collection DataSource Protocols

    
    
    // MARK: Collection Sections
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.loadPhotos.sections?.count ?? 0
        
    }//END OF FUNC: numberOfSectionsInCollectionView

    
    
    // MARK: Collection Items
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.loadPhotos.sections![section]
        return sectionInfo.numberOfObjects
        
    }//END OF FUNC: collectionView numberOfItemsInSection

    

    // MARK: Collection Views For Items

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoViewCell", forIndexPath: indexPath) as! PhotoViewCell
        
        let photo = loadPhotos.objectAtIndexPath(indexPath) as! Photo
        
        cellSettings(cell, photo: photo)
        
        return cell
    
    }//END OF FUNC: collectionView cellForItemAtIndexPath

    
    
    // MARK: Collection Selected Cells
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoViewCell
        
        let photo = loadPhotos.objectAtIndexPath(indexPath) as! Photo
        
        if let index = selectedPhotos.indexOf(photo) {
            selectedPhotos.removeAtIndex(index)
        } else {
            selectedPhotos.append(photo)
        }
        
        /* Configure the cell again to reflect its new selected or unselected status */
        cellSettings(cell, photo: photo)
        
        /* Update the bottom button to reflect whether a new collection should be added or selected items removed */
        collMessage.title = "Remove Selected Photos"
    }

    
    // MARK: Configure Cell
    
    func cellSettings(cell: PhotoViewCell, photo: Photo) {
        cell.backgroundColor = UIColor.orangeColor()
        
        //DEBUG: print (photo.photoImage)
        if photo.photoImage == nil {
            
            //Load new Photos for the Pin
            
            cell.photoCell.image = UIImage(named: "PlaceHolder")
            cell.photoLoading.startAnimating()
            
            FlickrAPI.sharedInstance().displayPhoto(photo) { (success, errorString) in
                if success {
                    performOnMain {
                        cell.photoCell?.image = photo.photoImage
                        cell.photoLoading.stopAnimating()
                    }
                } else {
                    performOnMain {
                        cell.photoCell.image = UIImage(named: "PlaceHolder")
                        cell.photoLoading.stopAnimating()
                        print(errorString)
                    }
                }
            }
            
        } else {
            
            // Load Stored Photos for the Pin
            
            performOnMain {
                cell.photoCell?.image = photo.photoImage
            }
        }
        
        // HighLight Selected Photos
        if let _ = selectedPhotos.indexOf(photo) {
            cell.alpha = 0.10
        } else {
            cell.alpha = 1.0
        }
        
    }//END OF FUNC: cellSettings

    @IBAction func collButton(sender: UIBarButtonItem) {
        //DEBUG: print("Pressed")
        //DEBUG: print(selectedPhotos.count)
        if (selectedPhotos.count == 0) {
            selpin.deleteAllPhotos()
            newCollectionPhotos()
            collMessage.title = "Loading New Photos...Select Photos to Delete"
        } else {
            selpin.deleteSelectedPhotos(selectedPhotos)
            selectedPhotos = [Photo]()
            collMessage.title = "Updating Photos...Select Photos to Delete"
        }
        
        
    }
    
    
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        //DEBUG: print("in controllerWillChangeContent")
        
    }//END OF FUNC: controllerWillChangeContent
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            //DEBUG: print("Insert an item")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            //DEBUG: print("Delete an item")
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            //DEBUG: print("Update an item.")
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            break
        }
        
    }//END OF FUNC: controller
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //DEBUG: print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
    }//END OF FUNC: controllerDidChangeContent

    

}//END OF FUNC: VTDetailsViewController