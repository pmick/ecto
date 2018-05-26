//
//  HorizontalSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/21/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import TwitchKit
import IGListKit
import UIKit

final class FeaturedViewModel: ListDiffable {
    let id: Int
    let title: String
    let imageUrl: URL
    
    let stream: TwitchKit.Stream
    
    init(featured: Featured) {
        self.id = featured.stream.id
        self.title = featured.title
        self.imageUrl = URL(string: featured.stream.preview.large)!
        
        self.stream = featured.stream
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

final class HorizontalSectionController: ListSectionController {
    private var items: [FeaturedViewModel]? {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.collectionViewDelegate = self
        adapter.dataSource = self
        return adapter
    }()
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 350)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(
            of: EmbeddedCollectionViewCell.self,
            for: self,
            at: index) as? EmbeddedCollectionViewCell else {
                fatalError()
        }
        adapter.collectionView = cell.collectionView
        return cell
    }
    
    override func didUpdate(to object: Any) {
        assert(object is List<FeaturedViewModel>)
        items = (object as? List<FeaturedViewModel>)?.items
    }
}

extension HorizontalSectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return items ?? []
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FeaturedStreamSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension HorizontalSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
