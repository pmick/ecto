//
//  M3U8Parser.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/19/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public struct M3UEntry: Equatable, Codable {
    public let codecs: String
    public let quality: String
    public let url: URL
    public let resolution: String?
}

struct M3UConstants {
    static let header = "#EXTM3U"
}

public enum M3UError: Error, Equatable {
    case headerMissing
    case valueMissing(key: String)
    case payloadEncodingInvalid
    case noEntries
}

struct M3UParser {
    func parse(_ contentsOfFile: String) throws -> [M3UEntry] {
        let lines = contentsOfFile.components(separatedBy: .newlines)
        
        guard let firstLine = lines.first,
            firstLine == M3UConstants.header else { throw M3UError.headerMissing }
        
        var entries: [M3UEntry] = []
        
        for (idx, line) in lines.enumerated() {
            let streamInfoPrefix = "#EXT-X-STREAM-INF:"
            if line.hasPrefix(streamInfoPrefix) {
                let info = line.replacingOccurrences(of: streamInfoPrefix, with: "")
                
                let dict = parse(info: info)
                
                let resolution = dict["RESOLUTION"]
                
                guard let codecs = dict["CODECS"] else {
                    throw M3UError.valueMissing(key: "CODECS")
                }
                
                guard let video = dict["VIDEO"] else {
                    throw M3UError.valueMissing(key: "VIDEO")
                }
                
                let nextLine = idx + 1
                guard nextLine < lines.count,
                    let url = URL(string: lines[nextLine]) else {
                    continue
                }
                
                entries.append(M3UEntry(codecs: codecs, quality: video, url: url, resolution: resolution))
            }
        }
        
        return entries
    }
    
    private func parse(info: String) -> [String: String] {
        var dict: [String: String] = [:]
        var keyBuffer: [Character] = []
        var valueBuffer: [Character] = []
        var readingKey = true
        var isInQuotedValue = false
        
        let quotationMark: Character = "\""
        let keyValueSeperator: Character = "="
        let keyValuePairSeperator: Character = ","
        let lineLength = info.count
        
        for (idx, character) in info.enumerated() {
            if idx == (lineLength - 1) {
                if character != quotationMark {
                    if readingKey {
                        keyBuffer.append(character)
                    } else {
                        valueBuffer.append(character)
                    }
                }
                
                dict[String(keyBuffer)] = String(valueBuffer)
                keyBuffer.removeAll()
                valueBuffer.removeAll()
            } else if character == quotationMark {
                isInQuotedValue = !isInQuotedValue
            } else if character == keyValuePairSeperator && !isInQuotedValue {
                readingKey = true
                dict[String(keyBuffer)] = String(valueBuffer)
                keyBuffer.removeAll()
                valueBuffer.removeAll()
            } else if character == keyValueSeperator {
                readingKey = false
            } else {
                if readingKey {
                    keyBuffer.append(character)
                } else {
                    valueBuffer.append(character)
                }
            }
        }
        
        return dict
    }
}
