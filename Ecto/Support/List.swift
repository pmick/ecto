//
//  List.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit

/// A container for an array that is list diffable
final class List<T>: ListDiffable {
    let items: [T]

    init(items: [T]) {
        self.items = items
    }

    func diffIdentifier() -> NSObjectProtocol {
        return "list" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}
