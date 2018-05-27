//
//  Resources.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/26/18.
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

public struct TopStreamsResource: Resource {    
    public typealias PayloadType = DataPayload<Stream>
    public let url = URL(string: "https://api.twitch.tv/helix/streams")!
    public var parameters: [String : String] = [:]
    public init() {}
}

public struct TopGamesResource: Resource {
    public typealias PayloadType = DataPayload<Game>
    public let url = URL(string: "https://api.twitch.tv/helix/games/top")!
    public var parameters: [String : String] = [:]
    public init() {}
}
