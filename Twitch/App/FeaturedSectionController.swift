//
//  FeaturedSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit
import TwitchKit

final class FeaturedSectionController: ListSectionController {
    private var featured: [Featured] = [] {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    private var indexPathOfPreviousStream: IndexPath?
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.collectionViewDelegate = self
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        return adapter
    }()
    
    private let paginationController = LegacyPaginatedRequestController(resource: FeaturedStreamsResource())
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        
        paginationController.loadData { result in
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

final class SpinnerViewModel: ListDiffable {
    let uuid = UUID()
    
    func diffIdentifier() -> NSObjectProtocol {
        return uuid as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

extension FeaturedSectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects: [ListDiffable] = [List(items:featured.map(StreamViewModel.init))]
        if paginationController.hasMorePages && !featured.isEmpty {
            objects.append(SpinnerViewModel())
        }
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is List<StreamViewModel>: return StreamsBindingController(scrollDirection: .horizontal)
        case is SpinnerViewModel: return SpinnerSectionController()
        default: fatalError("Not implemented. \(object) not supported.")
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension FeaturedSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return indexPathOfPreviousStream
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let nextIndexPath = context.nextFocusedIndexPath else { return }
        if !(adapter.sectionController(forSection: nextIndexPath.section) is SpinnerSectionController) {
            indexPathOfPreviousStream = nextIndexPath
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let context = collectionContext else { return }
        if scrollView.hasReachedTrailingEdge(withBuffer: context.containerSize.width * 2) {
            paginationController.loadMoreData { (result) in
                switch result {
                case .success(let welcome):
                    self.featured.append(contentsOf: welcome.featured)
                    print("Appending \(welcome.featured.count) more streams")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
