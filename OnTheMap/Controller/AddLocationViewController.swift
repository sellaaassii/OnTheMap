//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-16.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findlocationButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    var coordinateToDisplay: CLLocationCoordinate2D!
    var linkToAdd: String!
    var locationInString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelLocation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    //TODO: Show appropriate error message
    @IBAction func findLocation(_ sender: Any) {
        // check if student exists with get and Auth key:
        //    if yes: then we want to use the put location
        //    else: use the post location
        guard let location = locationTextField.text, let link = linkTextField.text, !location.isEmpty, !link.isEmpty else {
            //show alert
            showLocationFailure(message: "Please enter a location and a link")
            return
        }
        
        self.linkToAdd = link
        self.locationInString = location
        
        getCoordinateFromString(locationStringFromUser: self.locationInString, completion: self.handleGetCoordinate(success:error:))
    }

    func showLocationFailure(message: String) {
        let alertVC = UIAlertController(title: "Add Location Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }

    // inspiration from https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
    func getCoordinateFromString(locationStringFromUser: String, completion: @escaping (Bool, Error?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationStringFromUser) { placemarks, error in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let coordinate = placemark.location!.coordinate
                    
                    self.coordinateToDisplay = coordinate
                    completion(true, nil)
                    return
                }
            } else {
                completion(false, error)
            }
        }
    }

    func handleGetCoordinate(success: Bool, error: Error?) {
        if success {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationMapViewController") as! AddLocationMapViewController
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.coordinateToDisplay
            annotation.title = self.locationInString

            controller.annotation = annotation
            controller.url = self.linkToAdd
            controller.mapLocationString = self.locationInString

            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            showLocationFailure(message: error!.localizedDescription)
        }
    }
}
