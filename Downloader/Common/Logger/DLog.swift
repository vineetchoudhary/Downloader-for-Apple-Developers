//
//  DLog.swift
//  Downloader
//
//  Created by Vineet Choudhary on 21/06/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import CocoaLumberjack

struct DLog {
    private init() {
    }
    
    static func config() {
        DDLog.add(DDOSLogger.sharedInstance)
        
        if let ttyLogger = DDTTYLogger.sharedInstance {
            DDLog.add(ttyLogger)
        }
        
        let fileLogger = DDFileLogger()
        fileLogger.doNotReuseLogFiles = true
        fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
        DDLog.add(fileLogger)
    }
    
    static func verbose(_ message: String) {
        DDLogVerbose(message)
    }
    
    static func debug(_ message: String) {
        DDLogDebug(message)
    }
    
    static func info(_ message: String) {
        DDLogInfo(message)
    }
    
    static func warning(_ message: String) {
        DDLogWarn(message)
    }
    
    static func error(_ message: String) {
        DDLogError(message)
    }
}
