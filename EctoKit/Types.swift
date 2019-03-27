//
//  Types.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public struct PaginatedDataPayload<T>: Codable, PaginationCursorProviding where T: Codable {
    public let data: [T]
    public let pagination: Pagination

    public var cursor: String? { return pagination.cursor }
    public var hasMorePages: Bool { return !data.isEmpty }
}

public struct DataPayload<T>: Codable where T: Codable {
    public let data: [T]
}

public struct Stream: Codable {
    public let id: String
    public let userId: String
    public let gameId: String
    public let communityIds: [String]
    public let type: TypeEnum
    public let title: String
    public let viewerCount: Int
    public let startedAt: String
    public let language: String
    public let thumbnailUrl: String
}

public struct Game: Codable {
    public let id: String
    public let name: String
    public let boxArtUrl: String
}

public enum TypeEnum: String, Codable {
    case live
}

public struct Pagination: Codable {
    public let cursor: String
}

public struct User: Codable {
    public let login: String
    public let displayName: String
}
