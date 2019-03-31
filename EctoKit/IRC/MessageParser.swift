//
//  MessageParser.swift
//  EctoKit
//
//  Created by Patrick Mick on 3/29/19.
//

import Foundation
import UIKit

public struct IRCPrivateMessage {
    public let username: String
    public let userColor: UIColor?
    public let body: String
}

public struct IRCPrivateMessageParser {
    public func parse(_ input: String) -> IRCPrivateMessage? {
        guard input.hasPrefix("@") else { return nil }
        let components = input.components(separatedBy: " :")
        guard components.count == 3 else { return nil }
        guard components[1].components(separatedBy: .whitespaces).contains("PRIVMSG") else { return nil }
        let tags = parseTags(String(components[0].dropFirst()))
        let color = tags["color"].flatMap(UIColor.init(hex:))
        return IRCPrivateMessage(username: tags["display-name"]!, userColor: color, body: components[2])
    }
    
    private func parseTags(_ input: String) -> [String: String] {
        return input
            .components(separatedBy: ";")
            .reduce([:]) { (result, rawTag) -> [String: String] in
                let tagComponents = rawTag.components(separatedBy: "=")
                guard tagComponents.count > 1 else { return result }
                
                var resultCopy = result
                resultCopy[tagComponents[0]] = tagComponents[1]
                return resultCopy
        }
    }
}

public extension UIColor {
    convenience init?(hex: String) {
        let processedHex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            .uppercased()
        
        guard processedHex.count == 6 else { return nil }
        
        var rgbValue: UInt32 = 0
        Scanner(string: processedHex).scanHexInt32(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1
        )
    }
}
