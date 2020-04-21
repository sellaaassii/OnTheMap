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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var annotation: MKPointAnnotation!
    var mapLocationString: String!
    var url: String!
    var locations: [StudentInformation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        activityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.setCenter(annotation.coordinate, animated: true)
        
        let latitudeMeters = CLLocationDistance(exactly: 300)!
        let longitudeMeters = CLLocationDistance(exactly: 300)!
        
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: latitudeMeters, longitudinalMeters: longitudeMeters)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        
        let firstAnnotation = mapView.annotations[0]
        mapView.selectAnnotation(firstAnnotation, animated: true)
    }

    @IBAction func finishClicked(_ sender: Any) {
        // check if student has existing location before posting, but apparently this doesn't work because random unique key is generated every time a request is made
        activityIndicator.startAnimating()
        Client.getStudentLocations(uniqueKey: Client.Auth.accountKey, completion: handleCheckExistingStudent(results:error:))
}
    
    func handleCheckExistingStudent(results: [StudentInformation]?, error: Error?) {
        var objectId = ""
        if let results = results, results.count > 0 {
            objectId = results[0].objectId!
        }
        
        // for getting first name, last name and such
        Client.getPublicUserData(userId: Client.Auth.accountKey) { response, error in
            if error != nil {
                self.activityIndicator.stopAnimating()
                self.showMessage(message: error!.localizedDescription, title: "Add Location Failed")
            } else if let response = response {

                let student = StudentInformation(objectId: objectId, uniqueKey: response.key, firstName: response.firstName, lastName: response.lastName, mapString: self.mapLocationString, mediaURL: self.url, latitude: Float(self.annotation.coordinate.latitude), longitude: Float(self.annotation.coordinate.longitude))

                //the user id exists, meaning there are locations, so update existing location
                if !objectId.isEmpty {
                    Client.putStudentLocation(student: student, completion: self.handlePutPostStudentLocation(success:error:))
                } else {
                    // the user id does't exist, meaning there are no locations, so add new location by post
                    Client.postStudentLocation(student: student, completion: self.handlePutPostStudentLocation(success:error:))
                }
            }
        }
    }
    
    func handlePutPostStudentLocation(success: Bool, error: Error?) {
        activityIndicator.stopAnimating()
        if success {
            dismiss(animated: true, completion: nil)
        } else {
            showMessage(message: error!.localizedDescription, title: "Add Location Failed")
        }
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
            pinView?.pinTintColor   = MKPinAnnotationView.redPinColor()
        }

        return pinView
    }
    
    
}
