//
//  Environment.swift
//  TwitchKit
//
//  Created by Patrick Mick on 2/10/19.
//  Copyright © 2019 Patrick Mick. All rights reserved.
//

import Foundation

struct Environment {
    static var clientId: String {
        let clientId = ProcessInfo.processInfo.environment["API_CLIENT_ID"]
        assert(clientId != nil, "You need to have a `API_CLIENT_ID` environment variable set to run this project.")
        return clientId!
    }
}
