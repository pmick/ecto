//
//  TopStreamsSectionController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import IGListKit
import TwitchKit

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
        adapter.scrollViewDelegate = self
        return adapter
    }()
        
    private let paginationController = PaginatedRequestController(resource: StreamsResource())
    private var indexPathOfPreviousStream: IndexPath?
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        paginationController.loadData { (result) in
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
        var objects: [ListDiffable] = [List(items: streams.map(StreamViewModel.init))]
        if paginationController.hasMorePages && !streams.isEmpty {
            objects.append(SpinnerViewModel())
        }
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is List<StreamViewModel>: return StreamsBindingController(scrollDirection: .horizontal)
        case is SpinnerViewModel:
            return SpinnerSectionController()
        default: fatalError("Not implemented. \(object) not supported.")
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension TopStreamsSectionController: UICollectionViewDelegate {
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
                    self.streams.append(contentsOf: welcome.data)
                    print("Appending \(welcome.data.count) more streams")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
