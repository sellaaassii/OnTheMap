//
//  StudentLocationModel.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-15.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation
import MapKit

class StudentLocationModel {
    static var locationsPast         = [StudentLocation]()
    static var locationsRecent   = [StudentLocation]()
    
    class func clearAll() {
       locationsPast         = [StudentLocation]()
       locationsRecent   = [StudentLocation]()
    }
}
