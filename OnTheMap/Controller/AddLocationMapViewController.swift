//
//  AddLocationMapViewController.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-17.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class AddLocationMapViewController: UIViewController {
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var annotation: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
    }
    
    //TODO: CLEAN THIS UP
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        self.mapView.setCenter(annotation.coordinate, animated: true)
        
        let latitudeMeters = CLLocationDistance(exactly: 300)!
        let longitudeMeters = CLLocationDistance(exactly: 300)!
        
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: latitudeMeters, longitudinalMeters: longitudeMeters)
        self.mapView.addAnnotation(annotation)
        self.mapView.setRegion(region, animated: true)
        
        let firstAnnotation = self.mapView.annotations[0]
        self.mapView.selectAnnotation(firstAnnotation, animated: true)
    }

    
    @IBAction func finishClicked(_ sender: Any) {
        // POST STUDENT LOCATION
    }
    
}

extension AddLocationMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = MKPinAnnotationView.redPinColor()
        }

        return pinView
    }
    
    
}
