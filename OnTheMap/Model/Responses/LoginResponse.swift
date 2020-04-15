//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-14.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let account: UdacityAccountDetails
    let session: UdacitySessionDetails
}

struct UdacityAccountDetails: Codable {
    let registered: Bool
    let key: String
}

struct UdacitySessionDetails: Codable {
    let id: String
    let expiration: String
}
