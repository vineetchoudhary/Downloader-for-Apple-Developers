//
//  DownloadProgress.swift
//  Downloader
//
//  Created by Vineet Choudhary on 14/06/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation

struct DownloadProgress {
    var gid: String?
    var output: Aria2cOutput?
    var isFinish: Bool
    var fileName: String?
    var progress: String?
    var connections: String?
    var downloadSpeed: String?
    var uploadSpeed: String?
    var expectedTime: String?
    
    init(fileName: String, output: Aria2cOutput, isFinish: Bool = false) {
        self.output = output
        self.fileName = fileName
        self.isFinish = isFinish
        
        let outputComponents = output.output.components(separatedBy: " ")
        for component in outputComponents {
            if (component.hasPrefix("#")) {
                gid = component
            } else if (component.hasSuffix("%)")) {
                progress = component
            } else if (component.hasPrefix("CN")) {
                connections = component
            } else if (component.hasPrefix("DL")) {
                downloadSpeed = component
            } else if (component.hasPrefix("UL")) {
                uploadSpeed = component
            } else if (component.hasPrefix("ETA")) {
                expectedTime = component
            }
        }
    }
}

extension DownloadProgress: CustomStringConvertible {
    var description: String {
        return "\(fileName ?? gid ?? "") - " +
            "\(progress ?? "") - " +
            "\(downloadSpeed ?? "")"
    }
}

extension DownloadProgress: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\n\ngid - \(gid ?? "")" +
            "\n\nfile name - \(fileName ?? "") - " +
            "\n\nprogress - \(progress ?? "") - " +
            "\n\nconnections - \(connections ?? "")" +
            "\n\ndownload speed - \(downloadSpeed ?? "") - " +
            "\n\nupload speed - \(uploadSpeed ?? "") - " +
            "\n\nexpected time to finish - \(expectedTime ?? "")"
    }
}
