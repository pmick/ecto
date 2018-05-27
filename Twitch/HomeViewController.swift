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

final class FeaturedSectionController: ListSectionController {
    private var featured: [Featured] = [] {
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

    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)

        Twitch().request(FeaturedStreamsResource()) { result in
            switch result {
            case .success(let welcome):
                self.featured = welcome.featured
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
}

extension FeaturedSectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return featured.map(StreamViewModel.init)
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FeaturedStreamSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension FeaturedSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

final class TopStreamsSectionController: ListSectionController {
    private var streams: [TwitchKit.Stream] = [] {
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
    
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        Twitch().request(TopStreamsResource()) { result in
            switch result {
            case .success(let welcome):
                self.streams = welcome.data
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
}

extension TopStreamsSectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return streams.map(StreamViewModel.init)
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FeaturedStreamSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension TopStreamsSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

final class TopGamesSectionController: ListSectionController {
    private var games: [Game] = [] {
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
    
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        Twitch().request(TopGamesResource()) { result in
            switch result {
            case .success(let welcome):
                self.games = welcome.data
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
}

final class GameViewModel: ListDiffable {
    let id: String
    let name: String
    let boxArtUrl: String
    
    init(game: Game) {
        self.id = game.id
        self.name = game.name
        self.boxArtUrl = game.boxArtUrl
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

extension TopGamesSectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return games.map(GameViewModel.init)
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return GameSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension TopGamesSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
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
