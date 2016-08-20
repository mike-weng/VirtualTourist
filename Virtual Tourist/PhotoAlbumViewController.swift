//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/28/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var pin: Pin!
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var selecting = false
    
    var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureMap()
        self.configureCollectionView()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.pin.photos.isEmpty {
            self.loadImages()
        }
    }
    
    func loadImages() {
        FlickrClient.sharedInstance().getPhotos(pin.coordinate, page: pin.currentPage, completionHandler: { (success, photos, error) in
            if success {
                for photo in photos! {
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageID = photo["id"] as? String else {
                        print("Cannot find key 'id' in \(photo)")
                        return
                    }
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photo["url_m"] as? String else {
                        print("Cannot find key 'url_m' in \(photo)")
                        return
                    }
                    let photo = Photo(id: imageID, imagePath: imageUrlString, context: self.sharedContext)
                    photo.pin = self.pin
                    CoreDataStackManager.sharedInstance().saveContext()
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })
                
            } else {
                print(error)
            }
        })

    }
    
    func configureCollectionView() {
        let space = 3.0 as CGFloat
        let flowLayout = UICollectionViewFlowLayout()
        let width = (self.view.frame.size.width - (2 * space))/space
        let height = (self.view.frame.size.height - (2 * space))/space
        
        // Set left and right margins
        flowLayout.minimumInteritemSpacing = space
        
        // Set top and bottom margins
        flowLayout.minimumLineSpacing = space
        
        if (width > height) {
            flowLayout.itemSize = CGSizeMake(height, height)
        } else {
            flowLayout.itemSize  = CGSizeMake(width, width)
        }
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    @IBAction func bottomButtonTouchUp(sender: AnyObject) {
        
        if selecting {
            self.selecting = false
            self.deleteSelectedPhotos()
        } else {
            self.pin.currentPage = Int(self.pin.currentPage) + 1
            for photo in self.pin.photos {
                self.sharedContext.deleteObject(photo)
            }
            self.loadImages()
        }
        CoreDataStackManager.sharedInstance().saveContext()

        self.updateButtons()
    }
    
    @IBAction func selectButtonTouchUp(sender: AnyObject) {
        self.selecting = true
        self.updateButtons()
    }
    
    func updateButtons() {
        if selecting {
            self.bottomButton.title = "Remove Selected Photos"
            self.selectButton.enabled = false
        } else {
            self.bottomButton.title = "New Collection"
            self.selectButton.enabled = true
        }
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            self.sharedContext.deleteObject(photo)
        }
        
        selectedIndexes = [NSIndexPath]()
    }
    
    func configureMap() {
        let span = MKCoordinateSpanMake(1, 1)
        let region = MKCoordinateRegion(center: self.pin.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.pin.coordinate
        self.mapView?.addAnnotation(annotation)
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        print("beginUpdates")

    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        case .Move:
            break
        }

    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView.performBatchUpdates({
            
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
        CoreDataStackManager.sharedInstance().saveContext()

        
        print("endUpdates")
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if selecting {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
            if let index = self.selectedIndexes.indexOf(indexPath) {
                self.selectedIndexes.removeAtIndex(index)
            } else {
                self.selectedIndexes.append(indexPath)
            }
            
            self.configureCell(cell, atIndexPath: indexPath)
        } else {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("DetailPhotoViewController") as! DetailPhotoViewController
            let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            controller.photo = photo
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func configureCell(cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        if photo.image == nil {
            let imageURL = NSURL(string: photo.imagePath!)
            let imageData = NSData(contentsOfURL: imageURL!)
            let image = UIImage(data: imageData!)
            photo.image = image
            print("is nil")
            
        }
        dispatch_async(dispatch_get_main_queue(), {
            cell.imageView!.frame = cell.contentView.bounds
            cell.imageView!.image = photo.image
        })
    
        // If the cell is "selected" it's color panel is grayed out
        // we use the Swift `find` function to see if the indexPath is in the array
        
        if let index = self.selectedIndexes.indexOf(indexPath) {
            cell.imageView.alpha = 0.5
        } else {
            cell.imageView.alpha = 1.0
        }

    }
    

    

}