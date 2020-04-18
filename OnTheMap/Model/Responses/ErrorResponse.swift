//
//  ErrorResponse.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-15.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let status: Int
    let error: String
    let code: Int?
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
