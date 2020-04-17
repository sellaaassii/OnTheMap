//
//  MapLocationTableViewController.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-16.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapLocationTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: REFACTOR
        let limit = 100
        let order = "-updatedAt"

        Client.getStudents(limit: limit, order: order) { response, error in
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

            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func reloadData() {
        self.tableView?.reloadData()
    }
}


extension MapLocationTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationModel.annotationsRecent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell")!
        
        let annotation = StudentLocationModel.annotationsRecent[indexPath.row]
        
        cell.textLabel?.text = annotation.title
        cell.detailTextLabel?.text = annotation.subtitle
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        let annotation = StudentLocationModel.annotationsRecent[indexPath.row]
        let url = annotation.subtitle
        
        if url!.isValidURL {
            var validUrl = url!

            if !(validUrl.hasPrefix("http://") || validUrl.hasPrefix("https://")) {
                validUrl = "https://" + validUrl
            }

            let app = UIApplication.shared
            print("url is loading")
            app.open(URL(string: validUrl)!, options: [:], completionHandler: nil)

        } else {
            return
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
