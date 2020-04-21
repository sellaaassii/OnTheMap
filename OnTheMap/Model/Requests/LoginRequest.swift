//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-14.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    let udacity: UdacityUsernamePassword
}

struct UdacityUsernamePassword: Codable {
    let username: String
    let password: String
}
