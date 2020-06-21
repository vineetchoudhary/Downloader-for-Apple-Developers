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
    static func config() {
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger = DDFileLogger()
        fileLogger.doNotReuseLogFiles = true
        fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
        DDLog.add(fileLogger)
    }
    
    static func verbose(message: String) {
        DDLogVerbose(message)
    }
    
    static func debug(message: String) {
        DDLogDebug(message)
    }
    
    static func info(message: String) {
        DDLogInfo(message)
    }
    
    static func warning(message: String) {
        DDLogWarn(message)
    }
    
    static func error(message: String) {
        DDLogError(message)
    }
}
