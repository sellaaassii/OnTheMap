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

        let limit = 100
        let order = "-updatedAt"

        Client.getStudentLocations(limit: limit, order: order) { response, error in
            if let error = error {
                self.showMessage(message: error.localizedDescription, title: "Connection Error")
                return
            }
            
            StudentLocationModel.locationsRecent = response ?? [StudentInformation]()

            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.reloadData()
        }
    }

    func reloadData() {
        tableView?.reloadData()
    }
}


extension MapLocationTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationModel.locationsRecent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell")!

        let location = StudentLocationModel.locationsRecent[indexPath.row]
        
        cell.textLabel?.text = "\(location.firstName!) \(location.lastName!)"
        cell.detailTextLabel?.text = location.mediaURL
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        let location = StudentLocationModel.locationsRecent[indexPath.row]

        let url = location.mediaURL
        
        if url!.isValidURL {
            var validUrl = url!

            if !(validUrl.hasPrefix("http://") || validUrl.hasPrefix("https://")) {
                validUrl = "https://" + validUrl
            }

            let app = UIApplication.shared
            app.open(URL(string: validUrl)!, options: [:], completionHandler: nil)

        } else {
            return
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
