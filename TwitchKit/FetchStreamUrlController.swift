//
//  FetchStreamUrlController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

public final class FetchStreamUrlController {
    public init() { }
    
    // TODO return more metadata than just url
    public func fetchStreamUrl(forStreamNamed name: String, completion: @escaping (Result<URL>) -> Void) {
        let twitch = Twitch()
        twitch.request(AuthenticateStreamResource(name: name)) { result in
            switch result {
            case .success(let accessToken):
                let resource = VideoUrlResource(name: name, token: accessToken.token, sig: accessToken.sig)
                twitch.requestM3u(resource) { (result) in
                    switch result {
                    case .success(let entries):
                        if let first = entries.first {
                            let url = first.url
                            completion(.success(url))
                        } else {
                            completion(.failure(M3UError.noEntries))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
