//
//  GameViewModel.swift
//  Twitch
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit
import TwitchKit

final class GameViewModel {
    let id: String
    let name: String
    let boxArtUrl: String
    
    let game: Game
    
    init(game: Game) {
        self.id = game.id
        self.name = game.name
        self.boxArtUrl = game.boxArtUrl
        
        self.game = game
    }
}

extension GameViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? GameViewModel else { return false }
        return id == object.id
    }
}
