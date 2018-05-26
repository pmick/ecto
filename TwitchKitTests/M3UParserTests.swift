//
//  M3UParser.swift
//  TwitchKitTests
//
//  Created by Patrick Mick on 5/19/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import XCTest

@testable import TwitchKit

class M3UParserTests: XCTestCase {
    var sut: M3UParser!

    override func setUp() {
        super.setUp()
        
        sut = M3UParser()
    }
    
    func testMissingHeader() {
        let payload = ""
        
        XCTAssertThrowsError(try sut.parse(payload)) { (error) in
            XCTAssertEqual(error as? M3UError, M3UError.headerMissing)
        }
    }
    
    func testNoTracks() {
        let payload = """
            #EXTM3U
            #EXT-X-TWITCH-INFO:NODE="video-edge-c67ae8.lax03"
            """
        XCTAssert(try sut.parse(payload).isEmpty)
    }
    
    func testMissingInfo() {
        let payload = """
            #EXTM3U
            #EXT-X-TWITCH-INFO:NODE="video-edge-c67ae8.lax03"
            #EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="chunked",NAME="1080p60 (source)",AUTOSELECT=YES,DEFAULT=YES
            #EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="avc1.4D402A,mp4a.40.2",VIDEO="chunked"
            https://video-weaver.lax03.hls.ttvnw.net/foobar.m3u8
            """
        
        XCTAssertThrowsError(try sut.parse(payload)) { (error) in
            XCTAssertEqual(error as? M3UError, M3UError.valueMissing(key: "RESOLUTION"))
        }
    }
    
    func testOneTrack() {
        let payload = """
            #EXTM3U
            #EXT-X-TWITCH-INFO:NODE="video-edge-c67ae8.lax03"
            #EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="chunked",NAME="1080p60 (source)",AUTOSELECT=YES,DEFAULT=YES
            #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=6708935,RESOLUTION=1920x1080,CODECS="avc1.4D402A,mp4a.40.2",VIDEO="chunked"
            https://video-weaver.lax03.hls.ttvnw.net/foobar.m3u8
            """
        let expectedEntries = [M3UEntry(codecs: "avc1.4D402A,mp4a.40.2", quality: "chunked", url: URL(string: "https://video-weaver.lax03.hls.ttvnw.net/foobar.m3u8")!, resolution: "1920x1080")]
        XCTAssertEqual(try sut.parse(payload), expectedEntries)
    }

    func testTwoTracks() {
        let payload = """
            #EXTM3U
            #EXT-X-TWITCH-INFO:NODE="video-edge-c67ae8.lax03"
            #EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="chunked",NAME="1080p60 (source)",AUTOSELECT=YES,DEFAULT=YES
            #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=6708935,RESOLUTION=1920x1080,CODECS="avc1.4D402A,mp4a.40.2",VIDEO="chunked"
            https://video-weaver.lax03.hls.ttvnw.net/foobar1.m3u8
            #EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="chunked",NAME="1080p60 (source)",AUTOSELECT=YES,DEFAULT=YES
            #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=6708935,RESOLUTION=1280x720,CODECS="avc1.4D402A,mp4a.40.2",VIDEO="chunked"
            https://video-weaver.lax03.hls.ttvnw.net/foobar2.m3u8
            """
        let expectedEntries = [
            M3UEntry(codecs: "avc1.4D402A,mp4a.40.2", quality: "chunked", url: URL(string: "https://video-weaver.lax03.hls.ttvnw.net/foobar1.m3u8")!, resolution: "1920x1080"),
            M3UEntry(codecs: "avc1.4D402A,mp4a.40.2", quality: "chunked", url: URL(string: "https://video-weaver.lax03.hls.ttvnw.net/foobar2.m3u8")!, resolution: "1280x720")
        ]
        XCTAssertEqual(try sut.parse(payload), expectedEntries)
    }
}
