//
//  Aria2cParser.swift
//  Downloader
//
//  Created by Vineet Choudhary on 19/02/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

typealias Aria2cOutput = (output: String, error: String?)

struct Aria2cParser {
    static func parse(string: String)-> Aria2cOutput {
        let lines = string.components(separatedBy: .newlines)
        if var readoutLine = lines.last(where: {$0.first == "[" && $0.last == "]"}) {
            readoutLine.removeFirst()
            readoutLine.removeLast()
            let output = readoutLine.trimmingCharacters(in: .whitespacesAndNewlines)
            return Aria2cOutput(output, nil)
        }
        
        if let possibleReadoutLine = lines.last(where: {$0.first == "["}),
            var readoutLine = possibleReadoutLine.components(separatedBy: "]")
                .last(where: {$0.first == "["}) {
            readoutLine.removeFirst()
            readoutLine.removeLast()
            let output = readoutLine.trimmingCharacters(in: .whitespacesAndNewlines)
            return Aria2cOutput(output, nil)
        }
        
        let lowercasedOutput = string.lowercased()
        if lowercasedOutput.contains("download completed") {
            let output = NSLocalizedString("DownloadCompleted", comment: "")
            return Aria2cOutput(output, nil)
        }
        
        if lowercasedOutput.contains("error") {
            let output = NSLocalizedString("DownloadError", comment: "")
            return Aria2cOutput(output, string)
        }
        
        if lines.filter({ $0.contains("***") || $0.contains("===") }).count > 0{
            return Aria2cOutput("", nil)
        }
        
        let output = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return Aria2cOutput(output, nil)
    }
}
