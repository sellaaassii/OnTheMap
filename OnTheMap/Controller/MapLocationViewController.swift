//
//  MapLocationViewController.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-15.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class MapLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let limit = 100
        let order = "-updatedAt"
        Client.getStudents(limit: limit, order: order) { response, error in
            StudentLocationModel.locations = response
            print("responses bro")
            
            for location in StudentLocationModel.locations {
                let latitude  = CLLocationDegrees(location.latitude)
                let longitude = CLLocationDegrees(location.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(location.firstName) \(location.lastName)"
                annotation.subtitle = location.mediaURL
                
                StudentLocationModel.annotations.append(annotation)
            }
            
            self.mapView.addAnnotations(StudentLocationModel.annotations)
            self.mapView.delegate = self
            
        }
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = MKPinAnnotationView.redPinColor()
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let url = view.annotation?.subtitle else { return }

        if url!.isValidURL {
            var validUrl = url!

            if !(validUrl.hasPrefix("http://") || validUrl.hasPrefix("https://")) {
                validUrl = "https://" + validUrl
            }

            if control == view.rightCalloutAccessoryView {
                let app = UIApplication.shared
                print("url is loading")
                app.open(URL(string: validUrl)!, options: [:], completionHandler: nil)
            }

        } else {
            return
        }
    }
}
