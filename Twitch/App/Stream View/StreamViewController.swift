//
//  StreamViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import os.log
import TwitchKit
import UIKit
import AVKit

final class StreamViewController: UIViewController {
    private let context: ChannelNameContext
    
    init(context: ChannelNameContext) {
        self.context = context
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
        
        switch context {
        case .lhs(let channelName):
            loadStream(forChannelName: channelName)
        case .rhs(let userId):
            loadStream(forUserId: userId)
        }
    }
    
    private func loadStream(forChannelName name: ChannelName) {
        let controller = FetchStreamUrlController()
        controller.fetchStreamUrl(forStreamNamed: name) { (result) in
            switch result {
            case .success(let url):
                self.embedPlayer(with: url)
            case .failure(let error):
                os_log("Error fetching stream url: %s", log: .network, type: .error, error.localizedDescription)
            }
        }
    }
    
    private func embedPlayer(with url: URL) {
        let c = AVPlayerViewController()
        let player = AVPlayer(url: url)
        c.player = player
        self.addChildViewController(c)
        c.view.frame = self.view.bounds
        self.view.addSubview(c.view)
        c.didMove(toParentViewController: self)
        player.play()
    }
    
    private func loadStream(forUserId id: UserId) {
        let resource = UsersResource(userId: id)
        Twitch().request(resource) { result in
            switch result {
            case .success(let data):
                // TODO: Show an error message if we don't pass the guard
                guard let channelName = data.data.first?.login else { return }
                self.loadStream(forChannelName: channelName)
            case .failure(let error):
                os_log("Error loading user: %s", log: .network, type: .error, error.localizedDescription)
            }
        }
    }
}
