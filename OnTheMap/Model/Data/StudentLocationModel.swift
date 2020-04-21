//
//  StudentLocationModel.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-15.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation

class StudentLocationModel {
    static var locationsPast         = [StudentInformation]()
    static var locationsRecent   = [StudentInformation]()
    
    class func clearAll() {
       locationsPast         = [StudentInformation]()
       locationsRecent   = [StudentInformation]()
    }
}
