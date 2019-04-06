//
//  StreamViewController.swift
//  Twitch
//
//  Created by Patrick Mick on 5/26/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import os.log
import EctoKit
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
                self.embedChildren(with: url, channelName: name)
            case .failure(let error):
                os_log("Error fetching stream url: %s", log: .network, type: .error, error.localizedDescription)
            }
        }
    }
    
    private func embedChildren(with url: URL, channelName: String) {
        let chatViewController = ChatViewController(channelName: channelName)
        self.addChild(chatViewController)
        self.view.addSubview(chatViewController.view)
        
        chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
        chatViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
        chatViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: chatViewController.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: chatViewController.view.bottomAnchor).isActive = true
        chatViewController.didMove(toParent: self)
        
        let c = AVPlayerViewController()
        let player = AVPlayer(url: url)
        c.player = player
        self.addChild(c)
        self.view.addSubview(c.view)
        
        c.view.translatesAutoresizingMaskIntoConstraints = false
        c.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        c.view.trailingAnchor.constraint(equalTo: chatViewController.view.leadingAnchor).isActive = true
        c.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: c.view.bottomAnchor).isActive = true
        
        c.didMove(toParent: self)
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
