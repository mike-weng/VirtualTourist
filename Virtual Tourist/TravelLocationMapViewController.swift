//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/27/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var longPressRecognizer: UILongPressGestureRecognizer? = nil
    var deleting = false

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        self.mapView.addGestureRecognizer(longPressRecognizer!)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        self.mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [MKAnnotation])
        fetchedResultsController.delegate = self
        mapView.delegate = self
        
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .Began {
            return
        }
        
        let pressPoint = recognizer.locationInView(self.mapView)
        let pressMapCoordinates = self.mapView.convertPoint(pressPoint, toCoordinateFromView: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pressMapCoordinates
        let pin = Pin(annotation: annotation, context: self.sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
    }

    @IBAction func editButtonTouchUp(sender: UIBarButtonItem) {
        if sender.title == "Edit" {
            self.deleting = true
            self.navigationController?.navigationBar.topItem?.title = "Tap a pin to delete"
            sender.title = "Done"
        } else {
            self.deleting = false
            self.navigationController?.navigationBar.topItem?.title = ""
            sender.title = "Edit"
        }
        
    }
}

extension TravelLocationMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.animatesDrop = true
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let pin = view.annotation as! Pin
        if deleting {
            self.sharedContext.deleteObject(pin)
            CoreDataStackManager.sharedInstance().saveContext()
        } else {
            let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            controller.pin = pin
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}


extension TravelLocationMapViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("beginUpdates")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let annotation = anObject as! MKAnnotation
        switch type {
        case .Insert:
            self.mapView.addAnnotation(annotation)
        case .Delete:
            self.mapView.removeAnnotation(annotation)
        case .Update:
            self.mapView.removeAnnotation(annotation)
            self.mapView.addAnnotation(annotation)
        case .Move:
            self.mapView.removeAnnotation(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
        
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("endUpdates")
    }
        
        
}



