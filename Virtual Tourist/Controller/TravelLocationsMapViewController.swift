//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 27/11/20.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePin: UIBarButtonItem!
    var dataController:DataController!

    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?
    let savedRegionKey: String = "savedRegion"
    var selectedAnnotation: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getPersistedLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deletePin.isEnabled = false
        reloadLocation()
    }
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            saveGeoCoordination(from: locationCoordinate)
        }
    }
    
    @IBAction func deletePin(_ sender: Any) {
        do {
            if let annotation = self.selectedAnnotation {
                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                fetchRequest.predicate = predicate
                let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try dataController.viewContext.execute(request)
                mapView.removeAnnotation(annotation)
                deletePin.isEnabled = false
            }
        } catch {
            print("There was an error!!")
        }
    }
    
    func copyLocation(_ annotation: MKPointAnnotation) {
        let location = Pin(context: dataController.viewContext)
        location.creationDate = Date()
        location.longitude = annotation.coordinate.longitude
        location.latitude = annotation.coordinate.latitude
        location.locationName = annotation.title
        location.country = annotation.subtitle
        location.pages = 0
        try? dataController.viewContext.save()
        let selectedPin = SelectedPin(pin: location)
        self.mapView.addAnnotation(selectedPin)
        
    }
    
    func saveGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            annotation.title = placemark.name ?? "Not Known"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.copyLocation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
        let selectedPin: SelectedPin = sender as! SelectedPin
        photoAlbumViewController.pin = selectedPin.pin
        photoAlbumViewController.dataController = dataController
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    func reloadLocation() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        dataController.viewContext.perform {
            do {
                let pins = try self.dataController.viewContext.fetch(request)
                self.mapView.addAnnotations(pins.map { pin in SelectedPin(pin: pin) })
            } catch {
                print("Error fetching Pins: \(error)")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        let pinAnnotation = annotation as! SelectedPin
        pinAnnotation.title = pinAnnotation.pin.locationName
        pinAnnotation.subtitle = pinAnnotation.pin.country
                
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func saveMapLocation() {
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: savedRegionKey)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.saveMapLocation()
    }
    
    func getPersistedLocation() {
        if let mapRegin = UserDefaults.standard.dictionary(forKey: savedRegionKey) {
            let location = mapRegin as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let _ = view.annotation else {
            return
        }
        self.selectedAnnotation = view.annotation as? MKPointAnnotation
        deletePin.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {
            return
        }
        do {
            if let annotation = view.annotation as? MKPointAnnotation {
                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = [sortDescriptor]
                guard let location = (try dataController.viewContext.fetch(fetchRequest) as! [Pin]).first else {
                    return
                }
                let annotationPin = SelectedPin(pin: location)
                self.performSegue(withIdentifier: "goToPhotoAlbum", sender: annotationPin)
            }
        } catch {
            print("There was an error!!")
        }
    }
}

