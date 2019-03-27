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
    func parse(_ data: Data) throws -> PayloadType
}

public extension Resource {
    public var parameters: [String: String] { return [:] }

    public func parse(_ data: Data) throws -> PayloadType {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PayloadType.self, from: data)
    }
}

public protocol PaginationCursorProviding {
    var cursor: String? { get }
    var hasMorePages: Bool { get }
}

public protocol NextPageContextProviding {
    var hasMorePages: Bool { get }
}

public protocol Paginated {
    associatedtype PayloadType: PaginationCursorProviding
    var cursor: String? { get }
    func copy(with cursor: String) -> Self
}

public protocol LegacyPaginated {
    associatedtype PayloadType: NextPageContextProviding

    func copy(with offset: Int) -> Self
}

public struct DynamicResource<T>: Resource where T: Decodable {
    public typealias PayloadType = T
    public let url: URL
    public init(url: URL) {
        self.url = url
    }
}

public struct FeaturedStreamsResource: Resource, LegacyPaginated {
    public typealias PayloadType = Welcome
    public let url = URL(string: "https://api.twitch.tv/kraken/streams/featured")!
    var offset: Int
    var limit: Int { return Twitch.Constants.legacyPageSize }

    public init(offset: Int = 0) {
        self.offset = offset
    }

    public var parameters: [String: String] {
        return [
            "limit": String(limit),
            "offset": String(offset)
        ]
    }

    public func copy(with offset: Int) -> FeaturedStreamsResource {
        return FeaturedStreamsResource(offset: offset)
    }
}

public struct AuthenticateStreamResource: Resource {
    private let name: String

    public typealias PayloadType = StreamAccessToken
    public var url: URL {
        return URL(string: "https://api.twitch.tv/api/channels/\(name)/access_token")!
    }
    public init(name: String) {
        self.name = name
    }
}

public struct StreamsResource: Resource, Paginated {
    public typealias PayloadType = PaginatedDataPayload<Stream>
    public let url = URL(string: "https://api.twitch.tv/helix/streams")!
    public let cursor: String?
    private let gameId: String?
    public init(gameId: String? = nil, cursor: String? = nil) {
        self.gameId = gameId
        self.cursor = cursor
    }

    public var parameters: [String: String] {
        var params: [String: String] = [:]

        if let gameId = gameId {
            params["game_id"] = gameId
        }

        if let cursor = cursor {
            params["after"] = cursor
        }

        return params
    }

    public func copy(with cursor: String) -> StreamsResource {
        return StreamsResource(gameId: gameId, cursor: cursor)
    }
}

public struct GamesResource: Resource, Paginated {
    public var cursor: String?
    public typealias PayloadType = PaginatedDataPayload<Game>
    public let url = URL(string: "https://api.twitch.tv/helix/games/top")!

    public init(cursor: String? = nil) {
        self.cursor = cursor
    }

    public var parameters: [String: String] {
        var params: [String: String] = [:]

        if let cursor = cursor {
            params["after"] = cursor
        }

        return params
    }

    public func copy(with cursor: String) -> GamesResource {
        return GamesResource(cursor: cursor)
    }
}

public struct UsersResource: Resource {
    public typealias PayloadType = DataPayload<User>
    public let url = URL(string: "https://api.twitch.tv/helix/users")!
    private let userId: String

    public init(userId: String) {
        self.userId = userId
    }

    public var parameters: [String: String] {
        return ["id": userId]
    }
}
