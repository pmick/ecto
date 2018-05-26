//
//  Twitch.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/19/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public protocol Resource {
    associatedtype PayloadType: Decodable
    var url: URL { get }
    var parameters: [String: String] { get }
}

public struct FeaturedStreamsResource: Resource {
    public typealias PayloadType = Welcome
    public let url = URL(string: "https://api.twitch.tv/kraken/streams/featured")!
    public var parameters: [String : String] = [:]
    public init() {}
}

public struct AuthenticateStreamResource: Resource {
    private let name: String

    public typealias PayloadType = StreamAccessToken
    public var url: URL {
        return URL(string: "https://api.twitch.tv/api/channels/\(name)/access_token")!
    }
    public var parameters: [String : String] = [:]
    public init(name: String) {
        self.name = name
    }
}

public struct VideoUrlResource: Resource {
    private let name: String
    private let token: String
    private let sig: String
    
    public typealias PayloadType = Welcome
    public var url: URL {
        return URL(string: "https://usher.ttvnw.net/api/channel/hls/\(name).m3u8")!
    }
    public var parameters: [String : String] {
        return [
            "player": "twitchweb",
            "token": token,
            "sig": sig,
            "allow_audio_only": String(true),
            "allow_source": String(true),
            "type": "any",
            "p": "123456",
            "Client-ID": "***REMOVED***"
        ]
    }
    
    public init(name: String, token: String, sig: String) {
        self.name = name
        self.token = token
        self.sig = sig
    }
}

public enum Result<T> {
    case success(T)
    case failure(Error)
}

struct EmptyResponseError: Error {}

public struct Twitch {
    public init() {}
    
    public func request<T>(_ resource: T, completion: @escaping (Result<T.PayloadType>) -> Void) where T: Resource {
        var request = URLRequest(url: resource.url)
        request.setValue("***REMOVED***", forHTTPHeaderField: "Client-ID")
        
//        resource.parameters.forEach { (key, value) in
//            let queryItem = URLQueryItem(name: key, value: value)
//
//        }
        
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
