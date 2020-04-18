//
//  UserInformation.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-17.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation

struct UserInformation: Codable {
    let lastName: String?
    let firstName: String?
    let nickname: String?
    let registered: Bool
    let imageURL: String?
    let key: String?

    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
        case nickname
        case registered = "_registered"
        case imageURL = "_image_url"
        case key
    }
}
