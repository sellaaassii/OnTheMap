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
    static var locations         = [StudentLocation]()
    static var annotationsPast   = [MKPointAnnotation]()
    static var annotationsRecent = [MKPointAnnotation]()
    
    class func clearAll() {
        StudentLocationModel.locations         = [StudentLocation]()
        StudentLocationModel.annotationsPast   = [MKPointAnnotation]()
        StudentLocationModel.annotationsRecent = [MKPointAnnotation]()
    }
}
