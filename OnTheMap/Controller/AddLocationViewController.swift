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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinateToDisplay: CLLocationCoordinate2D!
    var linkToAdd: String!
    var locationInString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func cancelLocation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findLocation(_ sender: Any) {
        guard let location = locationTextField.text, let link = linkTextField.text, !location.isEmpty, !link.isEmpty else {
            showMessage(message: "Please enter a location and a link", title: "Find Location Failed")
            return
        }
        
        linkToAdd        = link
        locationInString = location
        
        getCoordinateFromString(locationStringFromUser: locationInString, completion: handleGetCoordinate(success:error:))
    }

    // inspiration from https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
    func getCoordinateFromString(locationStringFromUser: String, completion: @escaping (Bool, Error?) -> Void) {
        setGettingLocation(true)
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
        setGettingLocation(false)
        if success {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationMapViewController") as! AddLocationMapViewController
            
            let annotation        = MKPointAnnotation()
            annotation.coordinate = coordinateToDisplay
            annotation.title      = locationInString

            controller.annotation = annotation
            controller.url        = linkToAdd
            
            controller.mapLocationString = locationInString

            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            showMessage(message: error!.localizedDescription, title: "Find Location Failed")
        }
    }
    
    func setGettingLocation(_ gettingLocation: Bool) {
        gettingLocation ? activityIndicator.startAnimating(): activityIndicator.stopAnimating()
        
        locationTextField.isEnabled = !gettingLocation
        linkTextField.isEnabled     = !gettingLocation
    }
    
    
}
