//
//  TwitchIRCController.swift
//  EctoKit
//
//  Created by Patrick Mick on 3/30/19.
//

import Foundation

public final class TwitchIRCController: IRCControllerDelegate {
    private enum Constants {
        static let hostname = "irc.chat.twitch.tv"
        static let port = 80
    }
    
    let ircController = IRCController(hostname: Constants.hostname, port: Constants.port)
    private let privateMessageParser = IRCPrivateMessageParser()
    
    public init(oauthToken: String, nickname: String, channelName: String) {
        ircController.delegate = self
        
        ircController.connect()
        ircController.send("CAP REQ :twitch.tv/tags twitch.tv/commands")
        ircController.send("PASS oauth:\(oauthToken)")
        ircController.send("NICK \(nickname)")
        ircController.send("JOIN #\(channelName)")
    }
    
    func controllerDidReceiveMessages(_ controller: IRCController, messages: [String]) {
        // if messages contains a ping we send back a pong
        let privateMessages = messages.compactMap(privateMessageParser.parse)
    }
}
