//
//  FirstViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/18/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit
import TwitchKit
import AVKit
import IGListKit

class FirstViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private var featured: [Featured] = [] {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.collectionViewDelegate = self
        
        Twitch().request(FeaturedStreamsResource()) { result in
            switch result {
            case .success(let welcome):
                self.featured = welcome.featured
            case .failure(let error):
                print(error)
            }
            
        }
    }
}

final class List<T>: ListDiffable {
    let items: [T]
    
    init(items: [T]) {
        self.items = items
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "list" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

extension FirstViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [List(items: featured.map(FeaturedViewModel.init))]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return HorizontalSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension FirstViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

//extension FirstViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//
//    }
//}

//extension FirstViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return featured.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let f = featured[indexPath.row]
//        cell.textLabel?.text = f.title
//        return cell
//    }
//}
//
//extension FirstViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = featured[indexPath.row]
//        let name = item.stream.channel.name
//
//        let twitch = Twitch()
//        twitch.request(AuthenticateStreamResource(name: name)) { result in
//            print(">>>>>> result: \(result)")
//            switch result {
//            case .success(let accessToken):
//                let resource = VideoUrlResource(name: name, token: accessToken.token, sig: accessToken.sig)
//                twitch.requestM3u(resource) { (result) in
//                    switch result {
//                    case .success(let entries):
//                        if let first = entries.first {
//                            let url = first.url
//                            let vc = AVPlayerViewController()
//                            let player = AVPlayer(url: url)
//
//                            vc.player = player
//
//                            player.play()
//                            self.present(vc, animated: true, completion: nil)
//
//                        }
//                        print(">>>>>> entries: \(entries)")
//                    case .failure(let error):
//                        print(">>>>>> error: \(error)")
//                    }
//                }
//            case .failure(let error):
//                print(">>>>>> error: \(error)")
//            }
//
//
//        }
//    }
//}
