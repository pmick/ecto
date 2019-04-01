//
//  IRCControllerTests.swift
//  EctoKitTests
//
//  Created by Patrick Mick on 3/21/19.
//

import XCTest

@testable import EctoKit

final class MockURLSessionStreamTask: URLSessionStreamTask {
    var capturedMinBytes: Int?
    var capturedMaxBytes: Int?
    var capturedTimeout: TimeInterval?
    var capturedCompletionHandler: ((Data?, Bool, Error?) -> Void)?
    override func readData(ofMinLength minBytes: Int, maxLength maxBytes: Int, timeout: TimeInterval, completionHandler: @escaping (Data?, Bool, Error?) -> Void) {
        capturedMinBytes = minBytes
        capturedMaxBytes = maxBytes
        capturedTimeout = timeout
        capturedCompletionHandler = completionHandler
    }
}

final class MockURLSession: URLSession {
    let mockStreamTask = MockURLSessionStreamTask()
    
    override func streamTask(withHostName hostname: String, port: Int) -> URLSessionStreamTask {
        return mockStreamTask
    }
}

final class IRCControllerTests: XCTestCase {
    func testConnectionFailure() {
        let session = MockURLSession()
        let sut = IRCController(hostname: "", port: 1, urlSession: session)
        // Need to mock both URLSession and URLSessionStreamTask
        sut.connect()
    }
}
