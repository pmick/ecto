//
//  Constants.swift
//  Twitch
//
//  Created by Patrick Mick on 5/18/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

struct Constants {
    let clientId: String
    
    init() {
        let path = Bundle.main.path(forResource: "Constants", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! [String: Any]
        clientId = dict["clientId"] as! String
    }
}
