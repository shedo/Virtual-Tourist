//
//  SelectedPin.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 29/11/20.
//

import Foundation
import MapKit

class SelectedPin: MKPointAnnotation {
    var pin: Pin

    init(pin: Pin){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
