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
    var student: StudentLocation!
    var locations: [StudentLocation]!
    
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

    // TODO: Show appropriate error message
    @IBAction func finishClicked(_ sender: Any) {
        // POST STUDENT LOCATION
        let userId = Client.Auth.accountKey

        // check if student has existing location before posting, but apparently this doesn't work because random unique key is generated every time a request is made
        Client.getStudentLocations(uniqueKey: userId, completion: handleCheckExistingStudent(results:error:))
}
    
    func handleCheckExistingStudent(results: [StudentLocation]?, error: Error?) {
        var objectId = ""
        if let results = results, results.count > 0 {
            objectId = results[0].objectId!
        }
        
        // for getting first name, last name and such
        Client.getPublicUserData(userId: Client.Auth.accountKey) { response, error in
            if let error = error {
                self.showLocationFailure(message: "Your session has timed out. Please try logging in again! 🙃")
            } else if let response = response {

                self.student = StudentLocation(objectId: objectId, uniqueKey: response.key, firstName: response.firstName, lastName: response.lastName, mapString: self.mapLocationString, mediaURL: self.url, latitude: Float(self.annotation.coordinate.latitude), longitude: Float(self.annotation.coordinate.longitude))

                if error == nil {
                    //the user id exists, meaning there are locations, so update existing location
                    //checking if the user exists with unique key is not working, which is why this is needed
                    if !objectId.isEmpty {
                        Client.putStudentLocation(student: self.student, completion: self.handlePutStudentLocation(success:error:))
                    } else {
                        Client.postStudentLocation(student: self.student, completion: self.handlePostStudentLocation(success:error:))
                    }
                } else {
                    // the user id does't exist, meaning there are no locations, so add new location by post
                    Client.postStudentLocation(student: self.student, completion: self.handlePostStudentLocation(success:error:))
                }
            }
        }
    }
    
    func handlePutStudentLocation(success: Bool, error: Error?) {
        if success {
            self.dismiss(animated: true, completion: nil)
        } else {
            // should probably check data returned
            showLocationFailure(message: "I dunno why but your post location ting nat working so could not update")
        }
    }
    
    func handlePostStudentLocation(success: Bool, error: Error?) {
        if success {
            self.dismiss(animated: true, completion: nil)
        } else {
            showLocationFailure(message: "I dunno why but your post location ting nat working so could not add")
        }
    }
    
    // TODO: REFACTOR ALL ALERT FUNCTIONS TO ONE
    func showLocationFailure(message: String) {
        let alertVC = UIAlertController(title: "Add Location Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
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
