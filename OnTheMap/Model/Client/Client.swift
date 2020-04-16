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
        case getStudents(limit: Int?, skip: Int?, order: String?, uniqueKey: String?)

        var stringValue: String {
            switch self {
            case .login:
                return Endpoints.base + "/session"
            case .getStudents(limit: let limit, skip: let skip, order: let order, uniqueKey: let uniqueKey):
                if let limit = limit, let skip = skip, let order = order, let uniqueKey = uniqueKey {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&skip=\(skip)&order=\(order)&uniqueKey=\(uniqueKey)"
                }
                if let limit = limit, let skip = skip, let order = order {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&skip=\(skip)&order=\(order)"
                }
                if let limit = limit, let skip = skip {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&skip=\(skip)"
                }
                if let order = order, let limit = limit {
                    return Endpoints.base + "/StudentLocation?order=\(order)&limit=\(limit)"
                }
                if let limit = limit {
                    return Endpoints.base + "/StudentLocation?limit=\(limit)"
                }
                if let order = order {
                    return Endpoints.base + "/StudentLocation?order=\(order)"
                }
                if let uniqueKey = uniqueKey {
                    return Endpoints.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
                }
                return Endpoints.base + "/StudentLocation"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
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
    
    class func getStudents(limit: Int? = nil, skip: Int? = nil, order: String? = "", uniqueKey: String? = "", completion: @escaping ([StudentLocation], Error?) -> Void) {
        let url = Endpoints.getStudents(limit: limit, skip: skip, order: order, uniqueKey: uniqueKey).url
        print("the endpoint: \(url)")
        taskForGETRequest(url: url, responseType: StudentLocationResponse.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
}
