//
//  GameSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation
import IGListKit
import Kingfisher

final class GameSectionController: ListSectionController {
    struct Constants {
        static let aspectRatio: CGFloat = (272/380)
    }

    private var viewModel: GameViewModel?

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height * Constants.aspectRatio, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueCellFromNib(GameCollectionViewCell.self, for: self, at: index),
            let viewModel = viewModel else {
                fatalError()
        }

        let scale = UIScreen.main.scale
        let width = cell.bounds.width * scale
        let height = cell.bounds.height * scale
        let url = URL(string: viewModel.boxArtUrl
            .replacingOccurrences(of: "{width}", with: String(Int(width)))
            .replacingOccurrences(of: "{height}", with: String(Int(height))))!
        let processor = RoundCornerImageProcessor(cornerRadius: 8, backgroundColor: .clear) >>
            ResizingImageProcessor(referenceSize: cell.bounds.size, mode: .aspectFill)
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .cacheSerializer(FormatIndicatedCacheSerializer.png),
            .transition(.fade(0.2))
        ]
        cell.imageView.kf.setImage(with: url, placeholder: nil, options: options)
        return cell
    }

    override func didUpdate(to object: Any) {
        assert(object is GameViewModel)
        viewModel = object as? GameViewModel

        if isLastSection {
            self.inset = .zero
        } else {
            self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 64)
        }
    }

    override func didSelectItem(at index: Int) {
        guard let viewModel = viewModel,
            let viewController = viewController else { return }
        let gameStreamsViewController = GameStreamsViewController(game: viewModel.game)
        viewController.show(gameStreamsViewController, sender: viewController)
    }
}
