//
//  StreamBindingSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/27/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit

enum ScrollDirection {
    case horizontal
    case vertical
}

final class StreamsBindingController: ListBindingSectionController<List<StreamViewModel>> {
    struct Constants {
        static let aspectRatio: CGFloat = (16/9)
        static let interitemSpacing: CGFloat = 64
        static let lineSpacing: CGFloat = 64
    }
    
    private let scrollDirection: ScrollDirection
    init(scrollDirection: ScrollDirection) {
        self.scrollDirection = scrollDirection
        
        super.init()
        
        self.dataSource = self
        self.minimumInteritemSpacing = Constants.interitemSpacing
        self.minimumLineSpacing = Constants.lineSpacing
    }
    
    override init() {
        fatalError("not implemented")
    }
}

extension StreamsBindingController: ListBindingSectionControllerDataSource {
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? List<StreamViewModel> else { return [] }
        return object.items
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let cell = sectionController.collectionContext?.dequeueReusableCell(withNibName: "FeaturedStreamCollectionViewCell", bundle: nil, for: self, at: index) as? FeaturedStreamCollectionViewCell else {
            fatalError()
        }
        
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        if scrollDirection == .horizontal {
            let height = collectionContext?.containerSize.height ?? 0
            let availableHeight = height - 70
            return CGSize(width: availableHeight * Constants.aspectRatio, height: height)
        } else {
            guard let collectionContext = collectionContext else { return .zero }
            let containerWidth = collectionContext.containerSize.width
            let availableWidth = containerWidth - (Constants.lineSpacing * 2) - (inset.left + inset.right)
            let cellWidth = floor(availableWidth / 3)
            let cellHeight = floor(cellWidth / Constants.aspectRatio)
            
            return CGSize(width: cellWidth, height: cellHeight+70)
        }
    }
    
    override func didSelectItem(at index: Int) {
        guard let obj = object?.items[index] else { return }
        let context = obj.stream.context
        let vc = StreamViewController(context: context)
        viewController?.show(vc, sender: self)
    }
}
