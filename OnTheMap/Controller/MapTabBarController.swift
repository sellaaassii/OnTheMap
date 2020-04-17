//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-16.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapTabBarController: UITabBarController {
    
    @IBAction func logoutTapped(_ sender: Any) {
        Client.logout() {
            DispatchQueue.main.async {
                StudentLocationModel.clearAll()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        
        if let count = self.viewControllers?.count, count < 2 {
            return
        }
        
        let limit = 100

        // TODO: REFACTOR / find better way of doing reload
        // RELOAD DATA FOR MAP VIEW
        var order = "updatedAt"
        
        Client.getStudents(limit: limit, order: order) { response, error in
                StudentLocationModel.locations = response
                StudentLocationModel.annotationsPast = [MKPointAnnotation]()

                for location in StudentLocationModel.locations {
                    let latitude  = CLLocationDegrees(location.latitude)
                    let longitude = CLLocationDegrees(location.longitude)

                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(location.firstName) \(location.lastName)"
                    annotation.subtitle = location.mediaURL

                    StudentLocationModel.annotationsPast.append(annotation)
            }
            
            let mapViewController = self.viewControllers?[0] as! MapLocationViewController
            mapViewController.reloadData()
        }
        
        // RELOAD DATA FOR TABLE VIEW
        order = "-updatedAt"
        Client.getStudents(limit: limit, order: order) { response, error in
            // should probably fix the locations in the student model🙃
            StudentLocationModel.locations = response
            StudentLocationModel.annotationsRecent = [MKPointAnnotation]()

            for location in StudentLocationModel.locations {
                let latitude  = CLLocationDegrees(location.latitude)
                let longitude = CLLocationDegrees(location.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(location.firstName) \(location.lastName)"
                annotation.subtitle = location.mediaURL

                StudentLocationModel.annotationsRecent.append(annotation)
            }

            let mapTableViewController = self.viewControllers?[1] as! MapLocationTableViewController
            mapTableViewController.reloadData()
        }
    }

    @IBAction func addLocation(_ sender: Any) {
        performSegue(withIdentifier: "addLocation", sender: nil)
    }
}
