//
//  Log.swift
//  Twitch
//
//  Created by Patrick Mick on 6/9/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation
import os.log

// Can't make wrapper functions because:
// https://stackoverflow.com/questions/50937765/why-does-wrapping-os-log-cause-doubles-to-not-be-logged-correctly

extension OSLog {
    public static var network: OSLog {
        return OSLog(subsystem: "com.pmick.ecto", category: "networking")
    }
}
