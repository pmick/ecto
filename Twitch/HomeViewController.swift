//
//  HomeViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/18/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit
import TwitchKit
import AVKit
import IGListKit

class HomeViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let model: [String] = ["featured", "top_streams", "top_games"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let object = object as? String else { fatalError() }
        switch object {
        case "featured": return FeaturedSectionController()
        case "top_streams": return TopStreamsSectionController()
        case "top_games": return TopGamesSectionController()
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
