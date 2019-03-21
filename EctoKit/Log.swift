//
//  Log.swift
//  EctoKit
//
//  Created by Patrick Mick on 3/21/19.
//

import Foundation
import os.log

// Can't make wrapper functions because:
// https://stackoverflow.com/questions/50937765/why-does-wrapping-os-log-cause-doubles-to-not-be-logged-correctly

extension OSLog {
    public static var network: OSLog {
        return OSLog(subsystem: "com.pmick.ecto", category: "networking")
    }
    
    public static var irc: OSLog {
        return OSLog(subsystem: "com.pmick.ecto", category: "irc")
    }
}
