//
//  TwitchIRCController.swift
//  EctoKit
//
//  Created by Patrick Mick on 3/30/19.
//

import Foundation

public final class TwitchIRCController: IRCControllerDelegate {
    public enum Constants {
        public static let hostname = "irc.chat.twitch.tv"
        public static let port = 80
        
        public static let ping = "PING :tmi.twitch.tv"
        public static let pong = "PONG :tmi.twitch.tv"
    }
    
    var ircController: IRCControllerProtocol
    private let privateMessageParser = IRCPrivateMessageParser()
    private let messagesReceivedHandler: ([IRCPrivateMessage]) -> Void
    
    public init(
        oauthToken: String,
        nickname: String,
        channelName: String,
        ircController: IRCControllerProtocol = IRCController(hostname: Constants.hostname, port: Constants.port),
        messagesReceivedHandler: @escaping ([IRCPrivateMessage]) -> Void) {
        self.messagesReceivedHandler = messagesReceivedHandler
        self.ircController = ircController
        
        self.ircController.delegate = self
        
        ircController.connect()
        ircController.send("CAP REQ :twitch.tv/tags twitch.tv/commands")
        ircController.send("PASS oauth:\(oauthToken)")
        ircController.send("NICK \(nickname)")
        ircController.send("JOIN #\(channelName)")
    }
    
    public func controllerDidReceiveMessages(_ controller: IRCControllerProtocol, messages: [String]) {
        if messages.contains(Constants.ping) { controller.send(Constants.pong) }
        // if messages contains a ping we send back a pong
        let privateMessages = messages.compactMap(privateMessageParser.parse)
        messagesReceivedHandler(privateMessages)
    }
}
