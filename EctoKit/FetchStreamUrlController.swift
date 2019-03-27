//
//  FetchStreamUrlController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public final class FetchStreamUrlController {
    public init() { }

    public func fetchStreamUrl(forStreamNamed name: String, completion: @escaping (Result<URL>) -> Void) {
        Twitch().request(AuthenticateStreamResource(name: name)) { result in
            switch result {
            case .success(let accessToken):
                completion(.success(self.makeHLSUrl(forStreamNamed: name, accessToken: accessToken)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func makeHLSUrl(forStreamNamed name: String, accessToken: StreamAccessToken) -> URL {
        let parameters: [String: String] = [
            "player": "twitchweb",
            "token": accessToken.token,
            "sig": accessToken.sig,
            "allow_audio_only": String(true),
            "allow_source": String(true),
            "type": "any",
            "p": "123456",
            "Client-ID": Environment.clientId
        ]

        var urlComponents = URLComponents(url: URL(string: "https://usher.ttvnw.net/api/channel/hls/\(name).m3u8")!, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = parameters.map(URLQueryItem.init)
        return urlComponents.url!
    }
}
