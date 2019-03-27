//
//  GameStreamsViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit
import EctoKit
import IGListKit
import os.log

final class GameStreamsViewController: UIViewController {
    private let game: Game
    private let paginationController: PaginatedRequestController<StreamsResource>

    private var streams: [EctoKit.Stream] = [] {
        didSet {
            guard isViewLoaded else { return }
            adapter.performUpdates(animated: true, completion: nil)
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(c)
        c.clipsToBounds = false
        c.translatesAutoresizingMaskIntoConstraints = false
        c.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        c.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: c.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: c.bottomAnchor).isActive = true
        return c
    }()

    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    init(game: Game) {
        self.game = game
        paginationController = PaginatedRequestController(resource: StreamsResource(gameId: game.id))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        _ = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.collectionViewDelegate = self
        adapter.scrollViewDelegate = self

        paginationController.loadData { (result) in
            switch result {
            case .success(let welcome):
                self.streams.append(contentsOf: welcome.data)
            case .failure(let error):
                os_log("Error loading game streams: %s", log: .network, type: .error, error.localizedDescription)
            }
        }
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.hasReachedBottom(withBuffer: view.bounds.height * 2) {
            paginationController.loadMoreData { (result) in
                switch result {
                case .success(let welcome):
                    self.streams.append(contentsOf: welcome.data)
                    os_log("Appending game more streams: %d", log: .network, type: .info, welcome.data.count)
                case .failure(let error):
                    os_log("Error paginating game streams: %s", log: .network, type: .error, error.localizedDescription)
                }
            }
        }
    }
}
