//
//  HeaderSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/27/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit

final class HeaderSectionController: ListSectionController {
    var title: String?
    
    override init() {
        super.init()
        
        inset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.headerVerticalOffset, right: 0)
    }
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        return CGSize(width: context.containerSize.width, height: Constants.headerHeight)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "HeaderCollectionViewCell", bundle: nil, for: self, at: index) as? HeaderCollectionViewCell,
            let title = title else {
                fatalError()
        }
        
        cell.titleLabel.text = title
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.title = object as? String
    }
}
