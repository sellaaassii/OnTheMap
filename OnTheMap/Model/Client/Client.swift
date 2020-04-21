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
        static var sessionId  = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case getStudentLocations(limit: Int?, skip: Int?, order: String?, uniqueKey: String?)
        case getPublicUserData(userId: String)
        case postLocation
        case putLocation(objectId: String)

        var stringValue: String {
            switch self {
            case .login:
                return Endpoints.base + "/session"
            case .getStudentLocations(limit: let limit, skip: let skip, order: let order, uniqueKey: let uniqueKey):
                if let limit = limit, let skip = skip, let order = order, let uniqueKey = uniqueKey, !order.isEmpty, !uniqueKey.isEmpty {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&skip=\(skip)&order=\(order)&uniqueKey=\(uniqueKey)"
                }
                if let limit = limit, let skip = skip, let order = order, !order.isEmpty {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&skip=\(skip)&order=\(order)"
                }
                if let limit = limit, let skip = skip {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&skip=\(skip)"
                }
                if let order = order, let limit = limit, !order.isEmpty {
                    return Endpoints.base + "/StudentLocation?order=\(order)&limit=\(limit)"
                }
                if let limit = limit {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)"
                }
                if let order = order, !order.isEmpty {
                    return Endpoints.base + "/StudentLocation?order=\(order)"
                }
                if let uniqueKey = uniqueKey, !uniqueKey.isEmpty {
                    return Endpoints.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
                }
                return Endpoints.base + "/StudentLocation"
            case .getPublicUserData(let userId):
                return Endpoints.base + "/users/\(userId)"
            case .postLocation:
                return Endpoints.base + "/StudentLocation"
            case .putLocation(let objectID):
                return Endpoints.base + "/StudentLocation/\(objectID)"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, rangeNeeded: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            let decoder = JSONDecoder()
            do {
                if !rangeNeeded {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } else {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range)
                    
                    let decoder = JSONDecoder()
                    let responseObject = try! decoder.decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }

        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, rangeNeeded: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody   = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                if !rangeNeeded {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } else {
                    let range = 5..<data.count
                    let dataWithoutSecurityCheck = data.subdata(in: range)
                    let responseObject = try decoder.decode(ResponseType.self, from: dataWithoutSecurityCheck)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }

        task.resume()
    }
    
    class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody   = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }

        task.resume()
    }

    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: UdacityUsernamePassword(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.login.url, responseType: LoginResponse.self, body: body, rangeNeeded: true) { response, error in
            if let response = response {
                Auth.accountKey = response.account.key
                Auth.sessionId  = response.session.id
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared

        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }

        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            Auth.accountKey = ""
            Auth.sessionId  = ""
            completion()
        }

        task.resume()
    }
    
    class func getStudentLocations(limit: Int? = nil, skip: Int? = nil, order: String? = "", uniqueKey: String? = "", completion: @escaping ([StudentInformation]?, Error?) -> Void) {
        let url = Endpoints.getStudentLocations(limit: limit, skip: skip, order: order, uniqueKey: uniqueKey).url
        taskForGETRequest(url: url, responseType: StudentLocationResponse.self, rangeNeeded: false) { response, error in
            if let response = response {
                completion(response.results, nil)
                return
            } else {
                completion([], error)
            }
        }
    }
    
    class func getPublicUserData(userId: String, completion: @escaping (UserInformation?, Error?) -> Void ) {
        let url = Endpoints.getPublicUserData(userId: userId).url
        
        taskForGETRequest(url: url, responseType: UserInformation.self, rangeNeeded: true) { response, error in
            if let response = response {
                completion(response, nil)
                return
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func postStudentLocation(student: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {

        taskForPOSTRequest(url: Endpoints.postLocation.url, responseType: StudentInformation.self, body: student, rangeNeeded: false) { response, error in
            if let response = response {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    class func putStudentLocation(student: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let url = Endpoints.putLocation(objectId: student.objectId!).url
        
        taskForPUTRequest(url: url, responseType: StudentInformation.self, body: student) { response, error in
            if let response = response {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

}
