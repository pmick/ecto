//
//  HorizontalSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/21/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import EctoKit
import IGListKit
import UIKit

typealias ChannelName = String
typealias UserId = String
typealias ChannelNameContext = Either<ChannelName, UserId>

protocol ChannelNameProviding {
    var context: ChannelNameContext { get }
}

extension LegacyStream: ChannelNameProviding {
    var context: ChannelNameContext {
        return .lhs(channel.name)
    }
}

extension EctoKit.Stream: ChannelNameProviding {
    var context: ChannelNameContext {
        return .rhs(userId)
    }
}

final class StreamViewModel: ListDiffable {
    let id: String
    let title: String
    let imageUrl: URL

    let stream: ChannelNameProviding

    init(featured: Featured) {
        self.id = String(featured.stream.id)
        self.title = featured.title
        self.imageUrl = URL(string: featured.stream.preview.large)!

        self.stream = featured.stream
    }

    init(stream: EctoKit.Stream) {
        self.id = stream.id
        self.title = stream.title
        let largePath = stream.thumbnailUrl
            .replacingOccurrences(of: "{width}", with: "640")
            .replacingOccurrences(of: "{height}", with: "360")
        self.imageUrl = URL(string: largePath)!

        self.stream = stream
    }

    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return false }
        guard let object = object as? StreamViewModel else { return false }
        return object.id == id &&
            object.title == title &&
            object.imageUrl == imageUrl
    }
}
