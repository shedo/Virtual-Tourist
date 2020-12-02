//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 27/11/20.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var loadingImages: UIActivityIndicatorView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController:DataController!
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapView()
        setupFetchedResultsController()
        loadImageFromFlickr()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func loadImageFromFlickr() {
        collectionView.isHidden = true
        loadingImages.isHidden = false
        loadingImages.startAnimating()
        
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            loadingImages.isHidden = true
            collectionView.isHidden = false
            loadingImages.stopAnimating()
            return
        }
        
        if let pin = pin {
            let pagesCount = Int(pin.pages)
            Client.getPhotos(latitude: pin.latitude,longitude: pin.longitude,
                             totalPageAmount: pagesCount) { (photos, totalPages, error) in
                
                if photos.count > 0 {
                    DispatchQueue.main.async {
                        self.collectionView.isHidden = false
                        self.loadingImages.isHidden = true
                        self.loadingImages.stopAnimating()
                        
                        if (pagesCount == 0) {
                            pin.pages = Int32(Int(totalPages))
                        }
                        for photo in photos {
                            let newPhoto = Photo(context: self.dataController.viewContext)
                            newPhoto.imageUrl = URL(string: photo.url_m)
                            newPhoto.imageData = nil
                            newPhoto.pin = self.pin
                            newPhoto.imageID = UUID().uuidString
                            
                            do {
                                try self.dataController.viewContext.save()
                            } catch {
                                print("Unable to save photo")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        guard let imageObject = fetchedResultsController.fetchedObjects else { return }
        for image in imageObject {
            dataController.viewContext.delete(image)
            do {
                try dataController.viewContext.save()
            } catch {
                print("Unable to delete images")
            }
        }
        loadImageFromFlickr()
    }
    
    func removeImage(photo: Photo) {
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print("Unable to remove the photo")
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        if let pin = pin {
            let predicate = NSPredicate(format: "pin == %@", pin)
            fetchRequest.predicate = predicate
        }
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: dataController.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: "photo")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func showAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath:  IndexPath?)
    {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
}
