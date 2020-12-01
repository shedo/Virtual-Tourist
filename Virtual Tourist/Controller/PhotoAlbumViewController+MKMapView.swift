//
//  PhotoAlbumViewController+MKMapView.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 01/12/20.
//

import Foundation
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reusedPinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedPinId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedPinId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            
        } else {
            pinView!.annotation = annotation
        }
        
        pinView?.isSelected = true
        pinView?.isUserInteractionEnabled = false
        return pinView
    }
    
    func configureMapView() {
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta:  0.015, longitudeDelta: 0.015)
        let coordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(SelectedPin(pin: pin!))
    }
    
}
