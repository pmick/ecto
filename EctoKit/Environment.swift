//
//  Environment.swift
//  TwitchKit
//
//  Created by Patrick Mick on 2/10/19.
//  Copyright © 2019 Patrick Mick. All rights reserved.
//

import Foundation

public struct Environment {
    public static var clientId: String {
        let clientId = ProcessInfo.processInfo.environment["API_CLIENT_ID"]
        assert(clientId != nil, "You need to have a `API_CLIENT_ID` environment variable set to run this project.")
        return clientId!
    }
    
    public static var oauthToken: String {
        let oauthToken = ProcessInfo.processInfo.environment["OAUTH_TOKEN"]
        assert(oauthToken != nil, "You need to have a `OAUTH_TOKEN` environment variable set to run this project.")
        return oauthToken!
    }
}
