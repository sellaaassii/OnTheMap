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
        let order = "-updatedAt"
        
        Client.getStudentLocations(limit: limit, order: order) { response, error in
            if let error = error {
                self.showMessage(message: error.localizedDescription, title: "Connection Error")
                return
            }
            
            StudentLocationModel.locationsRecent = response ?? [StudentInformation]()
            StudentLocationModel.locationsPast   = response ?? [StudentInformation]()
            
            let mapViewController      = self.viewControllers?[0] as! MapLocationViewController
            let mapTableViewController = self.viewControllers?[1] as! MapLocationTableViewController

            mapViewController.reloadData()
            mapTableViewController.reloadData()
        }
    }

    @IBAction func addLocation(_ sender: Any) {
        performSegue(withIdentifier: "addLocation", sender: nil)
    }
}
