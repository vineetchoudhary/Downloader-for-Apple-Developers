//
//  MenuItemActions.swift
//  Downloader
//
//  Created by Vineet Choudhary on 21/06/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import Cocoa

extension AppDelegate {
    
    func logsShowInFinderActionn() {
        let sortedLogFilePaths = DLog.sortedLogFilePath.compactMap{ URL(fileURLWithPath: $0) }
        NSWorkspace.shared.activateFileViewerSelecting(sortedLogFilePaths)
    }
    
    func logsShowInConsoleAppAction() {
        if let latestLogFilePath = DLog.sortedLogFilePath.first {
            NSWorkspace.shared.openFile(latestLogFilePath)
        }
    }
}
