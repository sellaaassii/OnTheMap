//
//  Client.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-14.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation

class Client {
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login


        var stringValue: String {
            switch self {
            case .login:
                return Endpoints.base + "/session"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    // TODO: Refactor into separate task for post requests
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"

        let body = LoginRequest(udacity: UdacityUsernamePassword(username: username, password: password))
        request.httpBody = try! JSONEncoder().encode(body)

        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()

            let range = 5..<data.count
            let dataWithoutSecurityCheck = data.subdata(in: range)
            print(String(data: dataWithoutSecurityCheck, encoding: .utf8)!)

            do {
                let responseObject = try decoder.decode(LoginResponse.self, from: dataWithoutSecurityCheck)
                Auth.accountKey = responseObject.account.key
                Auth.sessionId = responseObject.session.id
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: dataWithoutSecurityCheck)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
    
}
