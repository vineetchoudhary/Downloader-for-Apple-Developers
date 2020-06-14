//
//  Aria2cParser.swift
//  Downloader
//
//  Created by Vineet Choudhary on 19/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

struct Aria2cParser {
    static func parse(string: String)-> String {
        let lines = string.components(separatedBy: .newlines)
        if var readoutLine = lines.last(where: {$0.first == "[" && $0.last == "]"}) {
            readoutLine.removeFirst()
            readoutLine.removeLast()
            return readoutLine.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let possibleReadoutLine = lines.last(where: {$0.first == "["}),
            var readoutLine = possibleReadoutLine.components(separatedBy: "]")
                .last(where: {$0.first == "["}) {
            readoutLine.removeFirst()
            readoutLine.removeLast()
            return readoutLine.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if string.lowercased().contains("download completed") {
            return NSLocalizedString("DownloadComplete", comment: "")
        }
        
        if lines.filter({ $0.contains("***") || $0.contains("===") }).count > 0{
            return ""
        }
        
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
