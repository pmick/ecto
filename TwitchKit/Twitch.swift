//
//  Twitch.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/19/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

struct EmptyResponseError: Error {}

public struct Twitch {
    public struct Constants {
        public static let pageSize: Int = 20
        public static let legacyPageSize: Int = 25
    }
    
    public init() {}
    
    public func request<T>(_ resource: T, completion: @escaping (Result<T.PayloadType>) -> Void) where T: Resource {
        var urlComponents = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = resource.parameters.map({ (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        })
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("***REMOVED***", forHTTPHeaderField: "Client-ID")

        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode > 399 {
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let error = try decoder.decode(ApiError.self, from: data)
                        completion(.failure(error))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            
            if let data = data {
                do {
                    let payload = try resource.parse(data)
                    DispatchQueue.main.async {
                        completion(.success(payload))
                    }
                    
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(EmptyResponseError()))
            }
            }.resume()
    }
}
