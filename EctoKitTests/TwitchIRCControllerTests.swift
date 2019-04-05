//
//  TwitchIRCControllerTests.swift
//  EctoKitTests
//
//  Created by Patrick Mick on 4/4/19.
//

import XCTest

@testable import EctoKit

private final class MockIRCController: IRCControllerProtocol {
    var delegate: IRCControllerDelegate?
    
    var connectCalled: Bool = false
    func connect() {
        connectCalled = true
    }
    
    var sentMessages: [String] = []
    func send(_ message: String) {
        sentMessages.append(message)
    }
}

final class TwitchIRCControllerTests: XCTestCase {
    func testConnectsAndJoinsChannelOnInit() {
        let ircController = MockIRCController()
        _ = TwitchIRCController(oauthToken: "secret", nickname: "alice", channelName: "bob", ircController: ircController) { (messages) in }
        
        XCTAssertTrue(ircController.connectCalled)
        let expectedMessages = [
            "CAP REQ :twitch.tv/tags twitch.tv/commands",
            "PASS oauth:secret",
            "NICK alice",
            "JOIN #bob"
        ]
        XCTAssertEqual(ircController.sentMessages, expectedMessages)
    }
    
    func testSendsPongAfterReceivingPing() {
        let ircController = MockIRCController()
        _ = TwitchIRCController(oauthToken: "test", nickname: "test", channelName: "test", ircController: ircController) { (messages) in }
        
        ircController.delegate?.controllerDidReceiveMessages(ircController, messages: ["PING :tmi.twitch.tv"])
        
        XCTAssertEqual(ircController.sentMessages.last, "PONG :tmi.twitch.tv")
    }
    
    func testForwardsParsedPrivateMessages() {
        let ircController = MockIRCController()
        var capturedPrivateMessages: [IRCPrivateMessage] = []
        _ = TwitchIRCController(oauthToken: "test", nickname: "test", channelName: "test", ircController: ircController) { (messages) in
            capturedPrivateMessages.append(contentsOf: messages)
        }
        
        let rawMessage = """
        @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#CC0000;display-name=NMVenom;emotes=;flags=;id=8903ca8e-df1a-439f-8336-f344ba2a4573;mod=0;room-id=60056333;subscriber=1;tmi-sent-ts=1553908688829;turbo=0;user-id=204742305;user-type= :nmvenom!nmvenom@nmvenom.tmi.twitch.tv PRIVMSG #tfue :What if i want some crocs
        """
        ircController.delegate?.controllerDidReceiveMessages(ircController, messages: [rawMessage])
        
        XCTAssertEqual(capturedPrivateMessages.first?.body, "What if i want some crocs")
        
    }
}
