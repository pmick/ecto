//
//  FeaturedStreamSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/21/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import TwitchKit
import IGListKit
import Kingfisher
import UIKit

final class FeaturedStreamSectionController: ListSectionController {
    struct Constants {
        static let aspectRatio: CGFloat = (16/9)
    }
    
    private var featuredViewModel: FeaturedViewModel?
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        let availableHeight = height - 70
        return CGSize(width: availableHeight * Constants.aspectRatio, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "FeaturedStreamCollectionViewCell", bundle: nil, for: self, at: index) as? FeaturedStreamCollectionViewCell,
        let featuredViewModel = featuredViewModel else {
            fatalError()
        }

        cell.titleLabel.text = featuredViewModel.title
        cell.imageView.kf.setImage(with: featuredViewModel.imageUrl)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        assert(object is FeaturedViewModel)
        featuredViewModel = object as? FeaturedViewModel
        
        if isLastSection {
            self.inset = .zero
        } else {
            self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 64)
        }
    }
    
    override func didSelectItem(at index: Int) {
        guard let viewModel = featuredViewModel,
            let viewController = viewController else { return }
        let vc = StreamViewController(stream: viewModel.stream)
        viewController.show(vc, sender: viewController)
    }
}
