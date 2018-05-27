//
//  GameStreamsViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit
import TwitchKit
import IGListKit

final class GameStreamsViewController: UIViewController {
    private let game: Game
    
    private var streams: [TwitchKit.Stream] = [] {
        didSet {
            guard isViewLoaded else { return }
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(c)
        c.constrainFillingSuperview()
        return c
    }()
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    init(game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
        
        Twitch().request(StreamsResource(gameId: game.id)) { (result) in
            switch result {
            case .success(let dataPayload):
                self.streams = dataPayload.data
            case .failure(let error):
                print("error fetching games for game id: \(game.id), error: \(error)")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.collectionViewDelegate = self
    }
}

extension GameStreamsViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [game.name as ListDiffable, List(items: streams.map(StreamViewModel.init))]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is String: return HeaderSectionController()
        default:
            let c = StreamsBindingController(scrollDirection: .vertical)
            c.inset = UIEdgeInsets(top: 0, left: view.safeAreaInsets.left, bottom: 0, right: view.safeAreaInsets.right)
            return c

        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension GameStreamsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 { return false }
        return true
    }
}
