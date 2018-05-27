//
//  StreamViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import TwitchKit
import UIKit
import AVKit

final class StreamViewController: UIViewController {
    private let name: String?
    
    init(name: String?) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("NOT IMPLEMENTED")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NOT IMPLEMENTED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let name = name else {
            fatalError("Not implemented")
        }
        
        let controller = FetchStreamUrlController()
        controller.fetchStreamUrl(forStreamNamed: name) { (result) in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    let c = AVPlayerViewController()
                    let player = AVPlayer(url: url)
                    c.player = player
                    self.addChildViewController(c)
                    c.view.frame = self.view.bounds
                    self.view.addSubview(c.view)
                    c.didMove(toParentViewController: self)
                    player.play()
                }
            case .failure(let error):
                print("error fetching stream url: \(error)")
            }
        }
    }
}
