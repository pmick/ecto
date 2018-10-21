//
//  SpinnerSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 6/2/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit

final class SpinnerSectionController: ListSectionController {
    override func sizeForItem(at index: Int) -> CGSize {
        guard let height = collectionContext?.containerSize.height else { fatalError("Missing context") }
        return CGSize(width: 300, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: SpinnerCell.self, for: self, at: index) as? SpinnerCell
            else { fatalError("Missing context or cell wrong type") }
        return cell
    }
}
