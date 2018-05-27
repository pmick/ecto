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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let payload = try decoder.decode(T.PayloadType.self, from: data)
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
    
    public func requestM3u<T>(_ resource: T, completion: @escaping (Result<[M3UEntry]>) -> Void) where T: Resource {
        var urlComponents = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)!
        
        let queryItems = resource.parameters.map { (arg) -> URLQueryItem in
            let (key, value) = arg
            return URLQueryItem(name: key, value: value)
        }
        
        urlComponents.queryItems = queryItems

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
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let error = try decoder.decode(ApiError.self, from: data)
                        completion(.failure(error))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            
            if let data = data {
                let decoder = M3UParser()
                do {
                    guard let contentsOfFile = String(data: data, encoding: .utf8) else {
                        completion(.failure(M3UError.payloadEncodingInvalid))
                        return
                    }
                    print("m3u8 payload: \(contentsOfFile)")
                    let payload = try decoder.parse(contentsOfFile)
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
