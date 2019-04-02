//
//  MessageParser.swift
//  EctoKit
//
//  Created by Patrick Mick on 3/29/19.
//

import Foundation
import UIKit

public struct EmoteUsageDescriptor: Equatable {
    public let emoteId: String
    public let ranges: [ClosedRange<Int>]
}

public struct EmoteMetadata: Equatable {
    public let emoteDescriptors: [EmoteUsageDescriptor]
}

public struct IRCPrivateMessage {
    public let username: String
    public let userColor: UIColor?
    public let body: String
    public let emoteMetadata: EmoteMetadata
}

extension ClosedRange where Bound == Int {
    init?(rawRange: String) {
        let bounds = rawRange.components(separatedBy: "-")
        assert(bounds.count == 2)
        guard bounds.count == 2,
            let lowerBound = Int(bounds[0]),
            let upperBound = Int(bounds[1]),
            upperBound > lowerBound else { return nil }
        self.init(uncheckedBounds: (lowerBound, upperBound))
    }
}

public struct IRCPrivateMessageParser {
    public func parse(_ input: String) -> IRCPrivateMessage? {
        guard input.hasPrefix("@") else { return nil }
        let components = input.components(separatedBy: " :")
        guard components.count == 3,
            components[1].components(separatedBy: .whitespaces).contains("PRIVMSG") else { return nil }
        let tags = parseTags(String(components[0].dropFirst()))
        let color = tags["color"].flatMap(UIColor.init(hex:))
        let rawEmotes = tags["emotes"]!
        
        let emoteUsageDescriptors: [EmoteUsageDescriptor]
        if rawEmotes.isEmpty {
            emoteUsageDescriptors = []
        } else {
            emoteUsageDescriptors = tags["emotes"]!.components(separatedBy: "/").compactMap { rawKeyValuePair -> EmoteUsageDescriptor? in
                let keyValuePairComponents = rawKeyValuePair.components(separatedBy: ":")
                assert(keyValuePairComponents.count == 2)
                let emoteId = keyValuePairComponents.first!
                let rawRanges = keyValuePairComponents.last!
                let individualRawRanges = rawRanges.components(separatedBy: ",").compactMap(ClosedRange<Int>.init)
                return EmoteUsageDescriptor(emoteId: emoteId, ranges: individualRawRanges)
            }
        }
        
        return IRCPrivateMessage(username: tags["display-name"]!, userColor: color, body: components[2], emoteMetadata: EmoteMetadata(emoteDescriptors: emoteUsageDescriptors))
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
