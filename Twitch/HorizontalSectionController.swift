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

typealias ChannelName = String
typealias UserId = String
typealias ChannelNameContext = Either<ChannelName, UserId>

protocol ChannelNameProviding {
    var context: ChannelNameContext { get }
}

enum Either<A, B> {
    case lhs(A)
    case rhs(B)
}

extension LegacyStream: ChannelNameProviding {
    var context: ChannelNameContext {
        return .lhs(channel.name)
    }
}

extension TwitchKit.Stream: ChannelNameProviding {
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
    
    init(stream: TwitchKit.Stream) {
        self.id = stream.id
        self.title = stream.title
        // 640x360
        let largePath = stream.thumbnailUrl.replacingOccurrences(of: "{width}", with: "640").replacingOccurrences(of: "{height}", with: "360")
        self.imageUrl = URL(string: largePath)!
        
        self.stream = stream
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

final class HorizontalSectionController: ListSectionController {
    private var items: [StreamViewModel]? {
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
        assert(object is List<StreamViewModel>)
        items = (object as? List<StreamViewModel>)?.items
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
