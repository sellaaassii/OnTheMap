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
    var mapLocationString: String!
    var url: String!
    var locations: [StudentInformation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
    }
    
    //TODO: CLEAN THIS UP
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        // check if student has existing location before posting, but apparently this doesn't work because random unique key is generated every time a request is made
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
                self.showMessage(message: "Your session has timed out. Please try logging in again! 🙃", title: "Session Timeout")
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
        if success {
            self.dismiss(animated: true, completion: nil)
        } else {
            showMessage(message: "Location could not be added 😫", title: "Add Location Failed")
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
