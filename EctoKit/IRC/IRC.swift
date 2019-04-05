//
//  IRC.swift
//  EctoKit
//
//  Created by Patrick Mick on 3/21/19.
//

import Foundation
import os.log

public protocol IRCControllerDelegate: class {
    func controllerDidReceiveMessages(_ controller: IRCControllerProtocol, messages: [String])
}

public protocol IRCControllerProtocol {
    var delegate: IRCControllerDelegate? { get set }
    
    func connect()
    func send(_ message: String)
}

public final class IRCController: IRCControllerProtocol {
    private enum Constants {
        static let messageSeparator = "\r\n"
        static let oneHour: TimeInterval = 60 * 60
    }
    
    public weak var delegate: IRCControllerDelegate?
    private var streamTask: URLSessionStreamTask
    
    public init(hostname: String, port: Int, urlSession: URLSession = .shared) {
        let hostname = "irc.chat.twitch.tv"
        let port = 80 // SSL Port. 6667 is the non-SSL port
        self.streamTask = urlSession.streamTask(withHostName: hostname, port: port)
        self.streamTask.resume()
    }
    
    public func connect() {
        streamTask.readData(ofMinLength: 0, maxLength: Int.max, timeout: Constants.oneHour) { [weak self] (data, atEOF, error) in
            if atEOF { return } // We stop our polling loop
            if let error = error {
                os_log("Error reading from irc connection %{public}@", log: .irc, type: .info, error.localizedDescription)
            }
            guard let data = data,
                let rawDecodedData = String(data: data, encoding: .utf8) else {
                    os_log("Got nil data", log: .irc, type: .info)
                    return
            }
            
            let messages = rawDecodedData.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: Constants.messageSeparator)
            messages.forEach { os_log("> %@", log: .irc, type: .info, $0) }
            
            if let `self` = self {
                self.delegate?.controllerDidReceiveMessages(self, messages: messages)
                self.connect()
            }
        }
    }
    
    public func send(_ message: String) {
        let data = (message + Constants.messageSeparator).data(using: .utf8)!
        streamTask.write(data, timeout: 60, completionHandler: { (error) in
            if let error = error {
                print("error sending irc message", message, error)
            } else {
                os_log("< %@", log: .irc, type: .info, message)
            }
        })
    }
}
