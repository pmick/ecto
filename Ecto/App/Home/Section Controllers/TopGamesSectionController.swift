//
//  TopGamesSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit
import EctoKit
import os.log

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
        adapter.scrollViewDelegate = self
        return adapter
    }()

    private let paginationController = PaginatedRequestController(resource: GamesResource())

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.sectionContentVerticalOffset, right: 0)
        paginationController.loadData { result in
            switch result {
            case .success(let welcome):
                self.games = welcome.data
            case .failure(let error):
                os_log("Error decoding top games: %s", log: .network, type: .error, error.localizedDescription)
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let context = collectionContext else { return }
        if scrollView.hasReachedTrailingEdge(withBuffer: context.containerSize.width * 2) {
            paginationController.loadMoreData { (result) in
                switch result {
                case .success(let welcome):
                    self.games.append(contentsOf: welcome.data)
                    os_log("Appending more top games %d", log: .network, type: .info, welcome.data.count)

                case .failure(let error):
                    os_log("Error loading more top games: %@", log: .network, type: .error, error.localizedDescription)

                }
            }
        }
    }
}
