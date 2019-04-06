//
//  TwitchUITests.swift
//  TwitchUITests
//
//  Created by Patrick Mick on 5/18/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import XCTest

class TwitchUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()
    }
}
