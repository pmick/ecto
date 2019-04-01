//
//  MessageParserTests.swift
//  EctoKitTests
//
//  Created by Patrick Mick on 3/29/19.
//

import XCTest

@testable import EctoKit

class MessageParserTests: XCTestCase {
    let parser = IRCPrivateMessageParser()
    
    func testParsingMessageBody() {
        let input = """
        @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#CC0000;display-name=NMVenom;emotes=;flags=;id=8903ca8e-df1a-439f-8336-f344ba2a4573;mod=0;room-id=60056333;subscriber=1;tmi-sent-ts=1553908688829;turbo=0;user-id=204742305;user-type= :nmvenom!nmvenom@nmvenom.tmi.twitch.tv PRIVMSG #tfue :What if i want some crocs
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result?.body, "What if i want some crocs")
        XCTAssertEqual(result?.username, "NMVenom")
        XCTAssertEqual(result?.userColor, UIColor(hex: "#CC0000"))

    }
    
    func testParsingADifferentMessageBody() {
        let input = """
        @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#0000FF;display-name=markwith_a_k;emotes=;flags=;id=9de967a4-0637-4844-bd8d-48e029411b14;mod=0;room-id=60056333;subscriber=1;tmi-sent-ts=1553908689322;turbo=0;user-id=206363491;user-type= :markwith_a_k!markwith_a_k@markwith_a_k.tmi.twitch.tv PRIVMSG #tfue :what u eating
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result?.body, "what u eating")
        XCTAssertEqual(result?.username, "markwith_a_k")
        XCTAssertEqual(result?.userColor, UIColor(hex: "#0000FF"))
    }
    
    func testParsingEmotes() {
        let input = """
        @badge-info=subscriber/3;badges=subscriber/3;color=;display-name=nbk_kush;emote-only=1;emotes=1215215:0-5,7-12,14-19,21-26,28-33,35-40,42-47,49-54;flags=;id=e5595811-91d0-40da-92cb-47645f1e529b;mod=0;room-id=60056333;subscriber=1;tmi-sent-ts=1553908711730;turbo=0;user-id=275926299;user-type= :nbk_kush!nbk_kush@nbk_kush.tmi.twitch.tv PRIVMSG #tfue :tfue20 tfue20 tfue20 tfue20 tfue20 tfue20 tfue20 tfue20
        """
        let result = parser.parse(input)
        
        XCTAssertEqual(result?.emoteMetadata, EmoteMetadata(emoteDescriptors: [EmoteUsageDescriptor(emoteId: "1215215", ranges: [0...5, 7...12, 14...19, 21...26, 28...33, 35...40, 42...47, 49...54])]))
    }
    
    func testParsingMultipleEmotes() {
        let input = """
        @badge-info=;badges=;color=#FF0000;display-name=brandon894200;emote-only=1;emotes=86:0-9,18-27/36:11-16;flags=;id=c7aecdcb-f8ce-4cc9-8724-9764d1c99ac2;mod=0;room-id=149747285;subscriber=0;tmi-sent-ts=1554081591081;turbo=0;user-id=417284793;user-type= :brandon894200!brandon894200@brandon894200.tmi.twitch.tv PRIVMSG #twitchpresents :BibleThump PJSalt BibleThump
        """
        let result = parser.parse(input)
        XCTAssertEqual(result?.emoteMetadata, EmoteMetadata(emoteDescriptors: [EmoteUsageDescriptor(emoteId: "86", ranges: [0...9, 18...27]), EmoteUsageDescriptor(emoteId: "36", ranges: [11...16])]))
    }
}
