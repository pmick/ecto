//
//  HomeViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/18/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit
import AVKit
import IGListKit
import EctoKit

final class HomeSectionModel: ListDiffable {
    let identifier: String
    
    init(_ identifier: String) {
        self.identifier = identifier
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? HomeSectionModel else { return false }
        return identifier == object.identifier
    }
}

final class HomeViewController: UIViewController {
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    let irc = TwitchIRCController(oauthToken: Environment.oauthToken, nickname: "tree2110", channelName: "tsm_daequan")

    let model: [ListDiffable] = [
        NSLocalizedString("Featured", comment: "") as ListDiffable,
        HomeSectionModel("featured"),
        NSLocalizedString("Top Streams", comment: "") as ListDiffable,
        HomeSectionModel("top_streams"),
        NSLocalizedString("Top Games", comment: "") as ListDiffable,
        HomeSectionModel("top_games")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.constrainFillingSuperview()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.collectionViewDelegate = self
    }
}

extension HomeViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return model as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case let headerTitle as String: return HeaderSectionController(title: headerTitle)
        case let sectionModel as HomeSectionModel where sectionModel.identifier == "featured": return FeaturedSectionController()
        case let sectionModel as HomeSectionModel where sectionModel.identifier == "top_streams": return TopStreamsSectionController()
        case let sectionModel as HomeSectionModel where sectionModel.identifier == "top_games": return TopGamesSectionController()
        default: assertionFailure("section of key \(object) not supported")
        }
        
        assertionFailure("section of key \(object) not supported")
        return FeaturedSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
